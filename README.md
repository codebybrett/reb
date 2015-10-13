reb
===

Home location for rebol scripts.

### Usage ###

    DO %env.reb

Subsequently as required:

    DO <script-file>

### env, script-needs ###

ENV is located in your BASE folder. ENV will record what that folder
is using what-dir.

Your BASE folder is a cache of copied scripts. If ENV cannot find a script
in your current or BASE folder it will look for it in MASTER.

MASTER is currently the folder in which this readme is located.

If you want your base to be a webservice use

    DO/ARGS %env.reb http://.../ ; Path to base folder.

SCRIPT-NEEDS declares the required files for a script and internally uses
ENV to find and DO those files.

### Note ###

Scripts here are written with the Ren/C project in mind and may use the
ren/c future bridge r2r3-future.r.

### License ###

If not otherwise specified for a file, files in this directory and
subdirectories should be read and understood as having the following license:

    (C) Copyright, Brett Handley

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
