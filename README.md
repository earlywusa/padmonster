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

#How to specify the monster range to update?
  ```Bash
  #change directory to padmonster
  $ cd padmonster
  #invoke the application with start_id and end_id, Note: end_id should greater than start_id
  #for example
  $ scrapy crawl padmonster -a start_id=1001 -a end_id=5000
  ```


# How to deploy the app to Heroku?

1. Install the Heroku CLI. You can find the download links in https://devcenter.heroku.com/articles/heroku-cli.

    [Optional] If you want to run Heroku CLI without installing it (e.g., you would like to run it on a computer without admin privileges), you can download the tarball version (zip file), and extract it. Let's say you extract it to C:/heroku. Then you add C:/heroku/bin to your PATH. You will then be able to invoke heroku commands in Terminal/Git Bash/Windows Command Prompt.

**All steps below are in Terminal/Git Bash/Windows Command Prompt.**

2. Clone the repo to your local folder:
    ```Bash
    # Change the directory below to where to put 'padmonster' as sub-folder
    $ cd C:/Users/jpan/apps/

    # Clone to C:/Users/jpan/apps/padmonster
    $ git clone https://github.com/earlywusa/padmonster.git padmonster
    $ cd padmonster
    ```

3. Login to your Heroku account
    ```Bash
    $ heroku login
    ```
    You will login through a browser.

4. Create a Heroku app if you haven't created it yet:
    ```Bash
    $ heroku create myapp --buildpack https://github.com/virtualstaticvoid/heroku-buildpack-r.git#heroku-16
    ```
    where *myapp* will be the name of your app.

    If you have created a Heroku app already, you only need to add the corresponding Heroku git repo to your remotes. You can do this by (assuming the name of the existing app is "padmonster"):
    ```Bash
    $ heroku git:remote -a padmonster
    ```
    This will add https://git.heroku.com/padmonster.git to your remotes. You can check the list of remotes by:
    ```Bash
    $ git remote -v
    ```
    and you should get something like:
    ```Bash
    heroku  https://git.heroku.com/padmonster.git (fetch)
    heroku  https://git.heroku.com/padmonster.git (push)
    origin  https://github.com/earlywusa/padmonster.git (fetch)
    origin  https://github.com/earlywusa/padmonster.git (push)
    ```

5. Push the codes to Heroku
    ```Bash
    $ git push heroku
    ```

6. You are all set! To view your live application, run
    ```Bash
    $ heroku open
    ```
    or go to http://myapp.herokuapp.com in your browser (replacing *myapp* by the name of your app).
