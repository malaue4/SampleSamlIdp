# Sample SAML Identity Provider (IdP)

This is a Ruby on Rails application that serves as a SAML 2.0 Identity Provider (IdP). It is built using the `saml_idp` gem and provides a sample implementation for authenticating users and responding to SAML requests from Service Providers (SPs).

## Stack

*   **Language:** Ruby 4.0.1
*   **Framework:** Rails 7.2.x
*   **Database:** PostgreSQL
*   **Frontend:** Bootstrap 5, Sass, Yarn for CSS bundling
*   **SAML Library:** [saml_idp](https://github.com/saml-idp/saml_idp)
*   **Process Manager:** Foreman (via `bin/dev`)

## Requirements

*   **Ruby:** ~> 3.3 (Check `.tool-versions` or `Dockerfile`)
*   **Node.js & Yarn:** Required for CSS bundling and assets.
*   **PostgreSQL:** Required for data storage.

## Setup

1.  **Clone the repository:**
    ```bash
    git clone <repository-url>
    cd SampleSamlIdp
    ```

2.  **Install dependencies:**
    ```bash
    bundle install
    yarn install
    ```

3.  **Database Configuration:**
    Ensure PostgreSQL is running. Copy/edit `config/database.yml` if necessary. The default configuration uses the `DB_HOST` environment variable or `localhost`.

4.  **Database Setup:**
    ```bash
    bin/rails db:prepare
    bin/rails db:seed
    ```
    The seed file generates sample users and sessions for testing.

## Running the Application

To start the Rails server and the CSS watcher simultaneously:

```bash
bin/dev
```

The application will be available at `http://localhost:3000` (default port).

## SAML Endpoints

The IdP provides the following SAML endpoints (prefixed by `/saml`):

*   **Metadata:** `GET /saml/metadata` - Returns the IdP's SAML metadata XML.
*   **SSO (Auth):** `GET/POST /saml/auth` - The Single Sign-On endpoint where SPs send `SAMLRequest`.
*   **Logout:** `MATCH /saml/logout` - Single Logout service endpoint.
*   **Attributes:** `GET /saml/attributes` - Endpoint for attribute authority.

## Environment Variables

| Variable | Description | Default |
| :--- | :--- | :--- |
| `DB_HOST` | PostgreSQL host | `localhost` |
| `PORT` | Application port | `3000` |
| `RAILS_ENV` | Rails environment (development/production) | `development` |
| `SAMPLE_SAML_IDP_DATABASE_PASSWORD` | Production DB password | |

## Scripts

*   `bin/dev`: Starts the development server using Foreman.
*   `bin/rails`: Standard Rails command-line tool.
*   `yarn build:css`: Compiles and prefixes Bootstrap CSS.
*   `yarn watch:css`: Watches for changes in SCSS files.

## Tests

The project uses Minitest for testing. To run the test suite:

```bash
bin/rails test
```

## Project Structure

*   `app/controllers/saml/`: Contains the `IdpController` which handles SAML requests.
*   `app/models/`: Contains `User` and `UserSession` models.
*   `config/initializers/saml_idp.rb`: Main configuration for the `saml_idp` gem, including certificates and service provider settings.
*   `db/seeds.rb`: Populates the database with fake user data.

## TODOs

*   [ ] Complete implementation of `AttributeAuthorityService` in `IdpController#attributes`.
*   [ ] Verify and update the `ruby` version in `.tool-versions` (currently shows 4.0.1 which might be future-dated or a typo).
*   [ ] Add more comprehensive system tests for SAML flows.

## License

This project is released under the [MIT License](LICENSE) (or specify otherwise if applicable). TODO: Add a LICENSE file.
