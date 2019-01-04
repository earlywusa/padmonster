Jobless Studio First Project~~

- padmonster_crawler

simple testing crawl tool for pad monsters

To execute:

cd padmonster

scrapy crawl padmonster

settings.py: configure crawler properties here

spiders/padmonster_speider.py : crawler main function

items.py: item configuration

models/* : model parser and database interaction


- DataStructure
define basic schema for the monsters

- app
server



# How to deploy the app to Heroku?

1. Install the Heroku CLI. You can find the download links in (https://devcenter.heroku.com/articles/heroku-cli).
    [Optional] If you want to run Heroku CLI without installing it (e.g., you would like to run it on a computer without admin privileges), you can download the tarball version (zip file), and extract it. Let's say you extract it to C:/heroku. Then you add C:/heroku/bin to your PATH. You will then be able to invoke heroku commands in Terminal/Git Bash/Windows Command Prompt.

All steps below are in Terminal/Git Bash/Windows Command Prompt.

2. Clone the repo to your local folder:
    ```Bash
    # Change below to the directory that will have 'padmonster' as its sub-folder
    $ cd C:/Users/jpan/apps/
    
    # clone to C:/Users/jpan/apps/padmonster
    $ git clone https://github.com/earlywusa/padmonster.git padmonster
    $ cd padmonster
    ```

3. Login to your Heroku account
    ```Bash
    $ heroku login
    ```

4. Create a Heroku app:
    ```Bash
    $ heroku create padmonster --buildpack https://github.com/virtualstaticvoid/heroku-buildpack-r.git#heroku-16
    ```

5. Push the codes to Heroku
    ```Bash
    $ git push heroku
    ```

6. You are all set! To view your live application, run
    ```Bash
    $ heroku open
    ``` 
