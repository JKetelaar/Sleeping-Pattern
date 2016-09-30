# Sleeping-Pattern

## How is this project configured
It's basically a directory with sub-projects.  
Each directory, containing r files, is a project. As each directory also contains a `.Rproj` file.

## How to initialize this project
Create a config.json with the following content:
```
{
	"twitter":{
		"api_key": "your_api_key",
		"api_secret": "your_api_secret",
		"access_token": "your_access_token",
		"access_token_secret": "your_secret_access_token"
	}
}
```
Whereas you fill the objects with the correct details from the [Twitter API](https://apps.twitter.com/).

Each project member already has a config.json in their Dropbox, this should be placed in the root folder of this project.  
This won't be pushed to this git, as it's in the `.gitignore` file.
