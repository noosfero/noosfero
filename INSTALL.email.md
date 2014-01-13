= Noosfero email setup

If you know mail systems well, you just need to make sure that the local MTA,
listening on localhost:25, is able to deliver e-mails to the internet. Any mail
server will do it. You can stop reading now.

If you are not an email specialist, then follow the instructions below. We
suggest that you use the Postfix mail server, since it is easy to configure and
very reliable. Just follow the instructions below.

To install Postfix:

# apt-get install postfix

During the installation process, you will be asked a few questions. Your answer
to them will vary in 2 cases:

Case 1: you can send e-mails directly to the internet. This will be the case
for most commercial private servers. Your answers should be:

  General type of mail configuration: Internet site
  System mail name: the name of your domain, e.g. "mysocialnetwork.com"

Case 2: you cannot, or don't want to, send e-mail directly to the internet.
This happens for example if your server is not allowed to make outbound
connections on port 25, or if you want to concentrate all your outbound mail
through a single SMTP server. Your answers in this case should be:

  General type of mail configuration: Internet with smarthost
  System mail name: the name of your domain, e.g. "mysocialnetwork.com"
  SMTP relay host: smtp.yourprovider.com

Note that smtp.yourprovider.com must allow your server to deliver e-mails
through it. You should probably ask your servive provider about this.

There is another possibility: if you are installing on a shared server, and
don't have permission to configure the local MTA, you can instruct Noosfero to
send e-mails directly through an external server. Please note that this should
be your last option, since contacting an external SMTP server directly may slow
down your Noosfero application server. To configure Noosfero to send e-mails
through an external SMTP server, follow the instructions on
http://noosfero.org/Development/SMTPMailSending

