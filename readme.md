# The epic gamer api

This api allows you to conveniently communicate witht the epic gamer api. If you dont know which functions you have 
access to, you can allways check it at [...]/api/list_funcs

## SQL database setup scripts
MariaDB scripts with all table, view, function and procedure declarations are available in database setup folder

## Requirements

 - python 3
 - [requests](https://pypi.org/project/requests/)

## Example use

```python
from teg_api import EpicGamerApi

api_key = "xyz"  # your api key
url_root = "abc"  # endpoint of the api, defaults to api on localhost
api = EpicGamerApi(api_key, url_root)

# simple call to api
resp = api.custom_call("articles", "getallarticles", {}) 
print(resp.json())

# list all available functions
resp = api.custom_call("list_funcs")

# simple call on all objects in a json file
responses = api.call_on_json_file("articles", "addarticle", "all_new_articles_are_in_this_json_file.json")
```