# Auth API Technical Summary for Flutter Dashboard

## 1) Scope and Assumptions for the Flutter Client App

This summary is written for the client-facing Flutter app only. The app will support end-user authentication flows for normal customers, not admin or store-owner dashboard flows.

Important scope note:

- The backend is a shared codebase and still contains admin/store-owner logic and routes.
- The client app will not implement those backend-only flows directly.
- For registration, the client app must still send the required `role` value expected by the backend shared codebase, but in this app the value will always be `client`.
- The API may still validate, reject, or gate access based on backend business rules that are part of the shared codebase, even though the Flutter app itself is client-only.

All auth endpoints are mounted under the backend app route prefix:

- Base path: `http://<backend-host>:<BACKEND_PORT>/auth`
- Example: `http://localhost:5000/auth`

> In the current backend, the auth router is mounted as `/auth` in [backend/index.js](index.js#L77). The endpoint definitions live in [backend/router/auth.js](router/auth.js#L1-L24).

## 2) Core Auth Flow for the Client Dashboard

### A. Registration

#### Endpoint

- `POST /auth/register`

#### Request body

```json
{
  "username": "john_doe2",
  "email": "user@example.com",
  "password": "SecurePass123",
  "confirmPassword": "SecurePass123",
  "role": "client",
  "phoneNumber": "01001234567",
  "address": {
    "city": "Cairo",
    "district": "Nasr City",
    "street": "Main Street"
  },
  "birthdate": "1990-01-15",
  "gender": "male",
  "session_id": "guest-session-id"
}
```

**Required fields:**

- `username` (3-64 characters, lowercase letters, numbers, underscores only)
- `email` (valid email format)
- `password` (8-64 characters, must include uppercase, lowercase, and digits)
- `confirmPassword` (must match password)
- `role` (must be "client" for Flutter app)

**Optional fields:**

- `phoneNumber` (Egyptian format: 01[0125]XXXXXXXX)
- `address` (object with city, district, street)
- `birthdate` (ISO date string)
- `gender` ("male" or "female")
- `session_id` (for merging guest cart)

#### Business logic

- Used when the user creates a new account in the client app.
- The backend validates the request body, rejects duplicate `email` or `username`, hashes the password, creates the client account, merges a guest cart if `session_id` is present, and immediately issues auth tokens.
- In this app, the registration form will always submit `role: "client"` because the backend is a shared codebase that still supports other account types, but the client app itself does not implement those flows.
- Backend-only admin/store-owner creation paths are still present in the shared repository, but they are outside the scope of the Flutter client app.

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

#### Request body

```json
{
  "email": "user@example.com"
}
```

**Required fields:**

- `email` (valid email format)

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

**For regular client login:**

```json
{
  "usernameOrEmail": "user@example.com",
  "password": "SecurePass123",
  "rememberMe": true,
  "session_id": "guest-session-id"
}
```

**For first-time admin/store_owner login (with activation token):**

```json
{
  "usernameOrEmail": "user@example.com",
  "password": "SecurePass123",
  "activationCode": "123456"
}
```

> Note: First-time admin/store_owner logins require a `?token=<activation-token>` query parameter

**Required fields:**

- `usernameOrEmail` (email or username)
- `password` (user's password)

**Optional fields:**

- `rememberMe` (boolean, for client preference)
- `session_id` (for guest cart merge, client only)
- `activationCode` (required only for first-time admin/store_owner login)

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

#### Request body

```json
{
  "email": "user@example.com"
}
```

**Required fields:**

- `email` (valid email format)

#### Business logic

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

#### Request body

```json
{
  "email": "user@example.com",
  "otp": "123456"
}
```

**Required fields:**

- `email` (valid email format)
- `otp` (6-digit OTP code sent to email)

#### Business logic

- Validates the OTP for the user.
- Allows only a limited number of attempts (3 attempts max).
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
  "newPassword": "NewSecurePass456",
  "confirmNewPassword": "NewSecurePass456"
}
```

**Required fields:**

- `email` (valid email format)
- `newPassword` (8-64 characters, must include uppercase, lowercase, and digits)
- `confirmNewPassword` (must match newPassword)

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

#### Request body

```json
{
  "phone": "+201001234567"
}
```

**Required fields:**

- `phone` (phone number in international format, e.g., +201001234567)

#### Business logic

- Sends a phone-based OTP to the target user via Twilio.
- The implementation is structured similarly to the email OTP flow.

#### Typical response

```json
{
  "message": "OTP sent successfully"
}
```

#### 2. Verify SMS OTP

- `POST /auth/sms/verify-otp`

#### Request body

```json
{
  "phone": "+201001234567",
  "otp": "123456"
}
```

**Required fields:**

- `phone` (phone number in international format)
- `otp` (6-digit OTP code sent via SMS)

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

### Backend-only/admin or store-owner flows

These flows exist in the shared backend but are not part of the client-only app scope:

1. `POST /auth/login?token=<activation-token>` for backend approval/activation processes
2. backend-admin or store-owner activation workflows
3. store-owner onboarding and approval steps

The client app should not expose these flows directly unless a separate admin or merchant dashboard is built later.

## 5) Auth Form Validation Rules and Client-Backend Alignment

The validation source of truth is not just one layer. For this backend, the real constraints come from three places combined:

1. model-level validations and schema constraints on the user/store data models
2. Zod validation schemas defined in `backend/validations/auth.js`
3. business-logic checks inside the auth controllers, including duplicate checks, role checks, token checks, OTP checks, and conditional flows

The Flutter client should mirror these constraints on the form layer so the user experience matches the API and does not fail immediately on submit.

### A. Registration form (`POST /auth/register`)

For the client app, the form should submit `role: "client"` because the backend shared codebase requires the field, but the actual client experience remains customer-only.

The backend expects:

- `username`
  - required
  - trimmed and lowercased
  - minimum 3 characters, maximum 64
  - allowed pattern: lowercase letters, numbers, underscores only
  - example valid value: `john_doe2`

- `email`
  - required
  - trimmed and lowercased
  - must be a valid email format
  - maximum 254 characters

- `password`
  - required
  - minimum 8 characters, maximum 64
  - must include at least one uppercase letter
  - must include at least one lowercase letter
  - must include at least one digit
  - `confirmPassword` must match the main password exactly

- `role`
  - required
  - only allowed values: `client` or `store_owner`

- optional profile fields
  - `phoneNumber`: optional Egyptian mobile format `01[0125]...` only
  - `address.city`, `district`, `street`: optional strings with max lengths 50/50/100
  - `birthdate`: optional valid date
  - `gender`: optional `male` or `female`

### B. Login form (`POST /auth/login`)

The backend expects:

- `usernameOrEmail`
  - required
  - accepted as either a valid email or a valid username
  - if it contains `@`, it must pass email validation
  - otherwise it must pass username rules

- `password`
  - required
  - same backend password rules as above

### C. Password reset flow (`POST /auth/password/send-otp`, `verify-otp`, `reset`)

The backend enforces:

- `email` must be valid and normalized
- `newPassword` must follow the same password constraints as registration/login
- `confirmNewPassword` must match `newPassword`
- OTP verification must occur before password reset is accepted

### D. Store-owner onboarding fields

When the dashboard handles store-owner registration, the API also validates:

- `store_name`: required, max 100 characters
- `store_email`: required, valid email
- `store_phone`: required, Egyptian phone format
- `store_address.city`, `district`, `street`: required with max lengths 50/50/100

### E. Important rule for the client UI

The frontend should only use validation that matches or is slightly more user-friendly than the backend rules. It should not add stricter rules that the API will reject, such as:

- requiring uppercase or lowercase in a way that differs from the server
- enforcing a different username pattern than the API allows
- allowing a password shorter than 8 or without required character classes
- accepting phone numbers outside the Egyptian numbering rule
- validating email or username formats differently than the backend
- trying to invent additional custom rules not present in the model/Zod/business logic validation chain

In practice, the real validation source of truth is the combined backend constraints: model validation, Zod schema rules, and controller business logic. The client-side form should mirror them closely and display the same error messages where possible to avoid inconsistent form states and failed requests.

### F. Scope-specific rule for this client app

Because this app is customer-only, the Flutter form should not expose fields or flows for:

- store-owner onboarding
- store-owner activation or approval
- admin account creation or admin dashboards
- backend-only role switching outside the fixed `client` value

The only role value the client app should send on registration is `client`, even though the backend shared codebase still expects the field as a required part of the request body.

## 6) Summary for Flutter Team

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
