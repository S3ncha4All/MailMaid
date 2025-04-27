# MailMaid
A CLI Tool for http-Requests

# Usage

mm history list

mm parse GET:https://test.com/?u=b&a=c||

mm get host -h -b 

mm request --method GET --header --body

mm help

# Features

## ToDo

- Complete Inputparameter parsing for URL and HTTP-Methods
- Add Header-Support
- Add Body-Support?

## Done

- Support all common HTTP-Methods
- POC Request with GET
- POC parsing Inputparameter

# Future loose Ideas
- Local History?
- Templates?
    - Split Templates into Header, Bodys, URL, and Method?
- Global and local variables
- Pre- and Post-Request Actions? Scripting? LUA <3?
- Script Store? Local Global?

