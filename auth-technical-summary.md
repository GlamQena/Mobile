# Auth API Technical Summary for Flutter Dashboard

## 1) Base URL

All auth endpoints are mounted under the backend app route prefix:

- Base path: `http://<backend-host>:<BACKEND_PORT>/auth`
- Example: `http://localhost:5000/auth`

> In the current backend, the auth router is mounted as `/auth` in [backend/index.js](index.js#L77). The endpoint definitions live in [backend/router/auth.js](router/auth.js#L1-L24).

## 2) Core Auth Flow for the Client Dashboard

### A. Registration

#### Endpoint
- `POST /auth/register`

#### Business logic
- Used when the user creates a new account from the dashboard.
- The backend validates the request body, rejects duplicate `email` or `username`, hashes the password, creates the correct user model (`client`, `store_owner`, etc.), merges a guest cart if `session_id` is present for a client, and immediately issues auth tokens.
- For `store_owner`, the account is created with `isActive: false` and `is_approved: false` until the admin review/activation flow completes.

#### Typical response
```json
{
  "message": "Verification link sent to your email to activate your created account!",
  "user": { "_id": "...", "email": "...", "role": "client" },
  "accessToken": "jwt-access-token",
  "refreshToken": "jwt-refresh-token",
  "cart_merged": false
}
```

#### Dashboard usage
- Call after the user fills the registration form.
- If the account is created successfully, the client should continue to the email verification step.

---

### B. Email Verification Request

#### Endpoint
- `POST /auth/email/send-token`

#### Business logic
- Used when the user needs to resend the verification link.
- The server checks whether the account exists and whether the email is already verified.
- If not verified, a new verification email link is sent.

#### Typical response
```json
{
  "message": "email verification link sent successfully"
}
```

#### Dashboard usage
- Use this when the user clicks “Resend verification link” on the dashboard.

---

### C. Verify Email Link

#### Endpoint
- `GET /auth/verify/:email/:token`

#### Business logic
- This is the link clicked from the email.
- The service verifies the signed JWT token and ensures the email in the token matches the URL email.
- If successful, the account is marked as verified and tokens are generated again.

#### Typical response
```json
{
  "message": "Email verified successfully",
  "user": { "_id": "...", "email": "...", "role": "client" }
}
```

#### Dashboard usage
- The Flutter app should open the link in a browser or deep-link handler and then redirect the user back into the app.
- After success, the dashboard can continue to normal login or profile onboarding.

---

### D. Login

#### Endpoint
- `POST /auth/login`

#### Request body
```json
{
  "usernameOrEmail": "user@example.com",
  "password": "********",
  "rememberMe": true,
  "session_id": "guest-session-id",
  "activationCode": "123456"
}
```

#### Business logic
- Finds the account by `email` or `username`.
- Validates the password.
- If the user is a `client`, optional guest cart merge can happen using `session_id`.
- If the user is `admin` or `store_owner` and is not active yet, a first-login flow is triggered.
- In the first-login path:
  1. The request must include a query token `?token=...`.
  2. The backend validates the activation token.
  3. The backend verifies the provided `activationCode`.
  4. The user is activated.
  5. A reset-password code is generated and sent by email.
  6. The API returns `requiresPasswordReset: true` and does not issue the full session yet.

#### Success response for active user
```json
{
  "success": true,
  "message": "Login successful",
  "user": { "_id": "...", "email": "...", "role": "client" },
  "accessToken": "jwt-access-token",
  "refreshToken": "jwt-refresh-token",
  "cart_merged": false
}
```

#### First-login response
```json
{
  "success": true,
  "message": "First login successful. Please set your password to continue.",
  "requiresPasswordReset": true,
  "userId": "...",
  "email": "user@example.com"
}
```

#### Dashboard usage
- Use this after the user enters the login form.
- For first-time `admin`/`store_owner` accounts, keep the user in a “set password” step, not a normal dashboard session.

---

### E. Forgot Password / Reset Password OTP

#### 1. Send OTP
- `POST /auth/password/send-otp`

#### Business logic
- Input: `{ "email": "user@example.com" }`
- Finds the user and creates or refreshes a reset-password OTP record.
- Sends the OTP to the user’s email.

#### Typical response
```json
{
  "message": "OTP sent to your email..."
}
```

#### Dashboard usage
- Trigger this when the user taps “Forgot password”.

---

#### 2. Verify OTP
- `POST /auth/password/verify-otp`

#### Business logic
- Validates the OTP for the user.
- Allows only a limited number of attempts.
- Marks the OTP as verified after success.

#### Typical response
```json
{
  "message": "OTP verified"
}
```

#### Dashboard usage
- Call after the user receives the code and enters it.
- If this step succeeds, the front-end can present the “new password” screen.

---

#### 3. Reset Password
- `POST /auth/password/reset`

#### Request body
```json
{
  "email": "user@example.com",
  "newPassword": "NewPass123",
  "confirmNewPassword": "NewPass123"
}
```

#### Business logic
- Checks that the OTP has already been verified.
- Hashes the new password and saves it.
- Marks the OTP record as no longer active for reuse.

#### Typical response
```json
{
  "message": "Password updated successfully..."
}
```

#### Dashboard usage
- Call only after the OTP has been verified.

---

### F. SMS OTP (If Needed by the Dashboard)

#### 1. Send SMS OTP
- `POST /auth/sms/send-otp`

#### Business logic
- Sends a phone-based OTP to the target user.
- The implementation is structured similarly to the email OTP flow.

#### Typical response
```json
{
  "message": "OTP sent successfully"
}
```

#### 2. Verify SMS OTP
- `POST /auth/sms/verify-otp`

#### Typical response
```json
{
  "message": "OTP verified"
}
```

#### Dashboard usage
- Use this only where the UI is expected to confirm a mobile verification step.

---

### G. Refresh Access Token

#### Endpoint
- `GET /auth/refresh-token`

#### Business logic
- Reads the refresh token from the `Authorization: Bearer ...` header or from the `refreshToken` cookie.
- Verifies the refresh token using `REFRESH_TOKEN_SECRET`.
- Loads the matching user by role and returns a fresh access token.

#### Typical response
```json
{
  "message": "access token refreshed successfully",
  "user": { "_id": "...", "role": "client" },
  "accessToken": "new-jwt-access-token"
}
```

#### Dashboard usage
- Call automatically when the access token is expired or missing.
- This is the right place to implement silent re-authentication in the Flutter dashboard.

---

### H. Logout

#### Endpoint
- `DELETE /auth/logout`

#### Business logic
- Signs the user out by clearing the auth cookies / session state.

#### Typical response
```json
{
  "message": "logged out successfully"
}
```

#### Dashboard usage
- Trigger this on the user’s sign-out action.

## 3) Auth Token Pattern

The backend uses two JWT layers:

- `accessToken`
  - Short-lived access session for API calls.
  - Should be used in the Flutter app for normal authenticated requests.

- `refreshToken`
  - Long-lived refresh session.
  - Stored in an HTTP-only cookie by the backend and also returned in the body on login/register.

### Important note for Flutter
- The backend sets the tokens as cookies with `httpOnly: true` and `sameSite: "lax"`.
- Because of that, the Flutter client should primarily treat the API as a cookie-aware session API when running on web, and as a bearer-aware API when the mobile app uses headers explicitly.

## 4) Recommended Dashboard Sequence

### Client registration workflow
1. `POST /auth/register`
2. `POST /auth/email/send-token` if the user needs another verification email
3. User clicks email verification link
4. `GET /auth/verify/:email/:token`
5. Login via `POST /auth/login`

### Password recovery workflow
1. `POST /auth/password/send-otp`
2. `POST /auth/password/verify-otp`
3. `POST /auth/password/reset`

### First-time admin/store-owner workflow
1. `POST /auth/login?token=<activation-token>` with activation code
2. Backend sends a reset-password code by email
3. Use `POST /auth/password/verify-otp`
4. Use `POST /auth/password/reset`
5. Then continue to the dashboard session flow

## 5) Summary for Flutter Team

The dashboard should treat auth as a multi-step state machine:

- `register -> verify email -> login`
- `forgot password -> send OTP -> verify OTP -> reset password`
- `login or refresh -> protected access -> refresh token when expired`

For the client dashboard, the most critical endpoints are:

- `POST /auth/register`
- `POST /auth/login`
- `GET /auth/refresh-token`
- `POST /auth/password/send-otp`
- `POST /auth/password/verify-otp`
- `POST /auth/password/reset`
- `DELETE /auth/logout`
