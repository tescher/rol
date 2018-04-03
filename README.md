# Habitat for Humanity Volunteer Management System

## Overview

Todo: add overview.

## Installation

You can setup this project on your local machine or a remote server using the following steps.

1. Clone the repository from the github project.
2. Install the required gems: `bundle install`
3. Create the database and load the seed data (see the Database section for details).
4. Run the server: `bin/rails server`

### Database Setup

This project uses [postgresql](https://www.postgresql.org/) as the backend database server and relies on some postgresql specific functionality ([fuzzystrmatch](https://www.postgresql.org/docs/9.1/static/fuzzystrmatch.html) extension).

After you have cloned the repository to a local directory take a look at `config/database.yml` to see the default settings.  Create a new database with the appropriate name (`rol_development` by default) and a new **super user** account (`hfh_rol_dev` by default).  Super user account is needed to enable the `fuzzystrmatch` postgresql extension.

Once you have created the database and the user, run the following commands to setup the database and load the sample data.

    $ rake db:setup
    $ rake db:seed

The seed file in the project (not for the tests) includes an initial user admin@example.com with password "password" so you can log in initially. You should disable this user after crfeating your own.
### Address Validation Setup

This project uses the FedEx API to verify addresses.  You'll need to [obtain a key](http://www.fedex.com/us/developer/web-services/index.html) and set up the following environment variables:

- RAILS_FEDEX_KEY
- RAILS_FEDEX_PASSWORD
- RAILS_FEDEX_ACCOUNT
- RAILS_FEDEX_METER
- RAILS_FEDEX_MODE
