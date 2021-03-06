# acctools

Set of command line tools to automate some accounting tasks. Tools include :

- **download_aba_statements**: download statements from Advanced Bank of Asia
- **format_bank_statement**: get csv or pdf bank statement ready for use in accounting software. Accepts PDF and csv statements from Crédit Industriel et Commercial (CIC), csv statements from Advanced Bank of Asia and Société Générale

## Tools summary

#### download_aba_statements

Prompts user for Advanced Bank of Asia i-banking credentials, tries to download statements, and saves them in pdf, csv, and xlsx formats, in default or custom destination directory. Handles cases of wrong password or wrong security device token.

Enables user to either let program calculate the cut-off date to download latest monthly statement, or specify start and end dates for the statements to download.

Examples:

    $ ./download_aba_statements.sh
    
    $ ./download_aba_statements.sh 2015-01-01 2015-12-31

Typical output:

    $ ./download_aba_statements.sh 2015-01-01 2015-12-31
    Username: JohnDoe
    Password: 
    CAP card token: 1234567890
    Starting...
    Opening page...
    Logging in...
    Verifying CAP Token...
    Logged in
    Generating data...
    Data generated
    Downloading statements...
    CSV file saved in 'ABA Bank Statement - 2015-01-01 to 2015-12-31/ABA Bank Statement - 2015-01-01 to 2015-12-31.csv'
    PDF file saved in 'ABA Bank Statement - 2015-01-01 to 2015-12-31/ABA Bank Statement - 2015-01-01 to 2015-12-31.pdf'
    XLS file saved in 'ABA Bank Statement - 2015-01-01 to 2015-12-31/ABA Bank Statement - 2015-01-01 to 2015-12-31.xlsx'
    Logging out...
    Logged out

<br>

#### format_bank_statement

Formats a given pdf or csv statement from Crédit Industriel et Commercial, or csv statement from Advanced Bank of Asia or Société Générale, to make it usable in accounting software, such as Wave accounting.

Removes unwanted lines from statement, keeps only list of transactions, and converts file to comma-delimited csv format.

Examples:

    $ ./format_bank_statement.sh downloaded_statement.csv
    
    $ ./format_bank_statement.sh downloaded_statement.csv clean_statement.csv

    $ ./format_bank_statement.sh "Extrait de comptes 12345 67891 011121314.. au 2015-10-31.pdf"

<br>

## Download

All download packages come ready to run. Once downloaded, unzip to a folder with spaces in path and start using :

    $ ./download_aba_statements.sh
    $ ./format_bank_statement.sh downloaded_statement.csv

Zip packages :

- [Mac OS X](https://github.com/vic-cw/acctools/releases/download/v0.1.1/acctools-0.1.1-macosx.zip)
- [Linux 64-bit](https://github.com/vic-cw/acctools/releases/download/v0.1.1/acctools-0.1.1-linux_64.zip)
    (issues on certain configurations)

Requirements :

- [java 8](http://www.oracle.com/technetwork/java/javase/downloads/jre8-downloads-2133155.html)
- [python](https://www.python.org/downloads)

## Developing

To develop, clone this repository and then:

- To build:

      $ ./gradlew assembleNoZip_macosx      // if under Mac OS X
      $ ./gradlew assembleNoZip_linux_64    // if under Linux

- To build and test:

      $ ./gradlew test_macosx               // if under Mac OS X
      $ ./gradlew test_linux_64             // if under Linux

- To build and run a specific command inside built folder:

      $ ./gradlew testRun_macosx <<<"./format_bank_statement.sh /Users/me/my_statement.csv"
      $ ./gradlew testRun_linux_64 <<<"./format_bank_statement.sh /Users/me/my_statement.csv"

[Node](https://nodejs.org/en/download) and [mocha](https://mochajs.org/#installation) are required to run some of the tests.

## License


    Copyright 2014-2018 Victor Combal-Weiss

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
