# Search OpCon Notifications
This SQL query searches all groups across machine, schedule, and job notifications with a variety of options.

# Disclaimer
No Support and No Warranty are provided by SMA Technologies for this project and related material. The use of this project's files is on your own risk.

SMA Technologies assumes no liability for damage caused by the usage of any of the files offered here via this Github repository.

# Prerequisites
- OpCon 17.1+ (has not been tested with earlier versions but may work)
- MS SQL

# Instructions

Run the query from SSMS or an OpCon SQL Agent job. You will possibly need to update the first line that starts with "use opconxps" to the name of your OpCon database.

Comparisons made using these variables are 'like' operations. A single percent sign (%) will match all values. Searches can be narrowed by providing strings for multiple variables.

Variables used in search include:

@message - string to search the entire message for.  Message includes all recipient addresses as well as the subject and body of the message. This query also searches the TOKEN table for the specified message string and looks to see if that property is being used as part of the message in any notifications. This variable is used most often to find all notifications sent to a particular email address, even if that address is stored as a property in the database.

    "Message" format (broken across multiple lines for readability here) is:

      <MAILTO> email address list </MAILTO>
      <MAILCC> email address list </MAILCC>
      <MAILBCC> email address list </MAILBCC>
      <MAILSUBJ> subject </MAILSUBJ>
      <MAILBODY> message body </MAILBODY>


@trigger can be searched for the triggering event such as 'job failed', 'job cancelled', 'job late to start', etc.

@actionType is generally 'E-Mail', but can be searched for 'OpCon/xps Event', 'Text Message', etc.

@selectString contains the machine, schedule, or job, depending on the type of message group


# License
Copyright 2019 SMA Technologies

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at [apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

# Contributing
We love contributions, please read our [Contribution Guide](CONTRIBUTING.md) to get started!

# Code of Conduct
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-v2.0%20adopted-ff69b4.svg)](code-of-conduct.md)
SMA Technologies has adopted the [Contributor Covenant](CODE_OF_CONDUCT.md) as its Code of Conduct, and we expect project participants to adhere to it. Please read the [full text](CODE_OF_CONDUCT.md) so that you can understand what actions will and will not be tolerated.
