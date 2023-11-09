# FoundryVTTMgmt
A git for automating management tasks for Foundry VTT hosts on cloud service providers


My last foundyvtt instance was an amazon ec2 ubuntu instance with node installed. It was simple and worked, except when broke it or eventually i ran out of dree credits.

Migrating was tough.

this repo will store my scripts for setting a docker host on azure for easier future migration.


user story, I download this git onto my pc. it uses batch/powershell to interact with azure and docker, providing a simple cmd line tool for setting up the azure instance and network as required for foundry, saving and shutting down (with key figures like az storage used), and booting up and loading.

The docker and azure commands should be isolated in seperate scripts where possibke, to ensure simole future migrations are simple.
