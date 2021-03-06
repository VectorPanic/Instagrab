# Instagrab
  
A shell script that retrieves multimedia content from user profiles on Instagram. The script uses a [Jest](https://jestjs.io/)-like interface and is easy to use. The script has been tested under macOS but should also work under Linux distributions.

![screenshot](https://drive.google.com/uc?id=1pC-Y-VzL7kGRBW_uqs8kVgAHDnjffyyO)

Instagrab has been tested on the following platforms:

* MacOS 10.14 (Mojave)
* Mac OS X 10.11.6 (El Capitan)
* Mac OS X 10.7.5 (Lion)

## How to use

Instagrab can be used to retrieve multimedia content from a specific user, or download content from multiple users at once.

### Single user download
  Call the script with the username of the Instagram account you want to download as an argument.   
The following example downloads all content from the user *[henkelunchar](https://www.instagram.com/henkelunchar/?hl=en)* and saves it in a folder of the same name.

```console
./instagrab.sh -u henkelunchar
```

### Milti user download

Instagrab offers an alternative script that uses a list of multiple users and retrieves the content from all user accounts at once.

Create a list in the users.txt file. Each user must be separated into a single row. The following example activates the script file that searches for **users.txt** in the same directory as the script file.

```console
./instagrab_batch.sh
```
