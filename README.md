# Habitat for Humanity Volunteer Management System

## Overview

Todo: add overview.

## Installation

You can setup this project on your local machine or a remote server using the following steps.

1. Clone the repository from the github project.
2. Install the required gems: `gem install`
3. Create the database and load the seed data (see the Database section for details).
4. Run the server: `bin/rails server`

### Database Setup

This project uses [postgresql](https://www.postgresql.org/) as the backend database server and relies on some postgresql specific functionality ([fuzzystrmatch](https://www.postgresql.org/docs/9.1/static/fuzzystrmatch.html) extension).

After you have cloned the repository to a local directory take a look at `config/database.yml` for the default settings.  Create a new database with the appropriate name (`rol_development` by default) and a new **super user** account (`hfh_rol_dev` by default).  Super user account is needed to enable the `fuzzystrmatch` postgresql extension.

Once you have created the database and the user run the following commands to the configure the database tables and load sample data.

    $ rails db:setup
    $ rails db:seed
