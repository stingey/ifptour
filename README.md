# README

This README would normally document whatever steps are necessary to get the
application up and running.

https://ifptour.herokuapp.com/

http://localhost:3000/users/sign_in
email: 'test@this.com', password: 'asdfasdf'

chal cred uname foosballadmin pword foosballadmin

How to reset PG Database on Heroku?
Step 1: heroku restart
Step 2: heroku pg:reset DATABASE (no need to change the DATABASE)
Step 3: heroku run rake db:migrate
Step 4: heroku run rake db:seed (if you have seed)
