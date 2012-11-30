Getting Started
---------------

Install Postgres and qt (install homebrew first, if you don't have it):

```bash
 brew update
 brew install postgresql
 brew install qt
```

Follow any additional instructions printed by the install. You can install an OSX preference pane here: https://github.com/mckenfra/postgresql-mac-preferences

Then:

```bash
git clone git@github.com:bcroesch/prophets.git
cd prophets
bundle
rails s thin
```