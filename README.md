## Creating a new repository based off of this template

This repository is a template.  To create a new repository based off of this one:

1. Click the green “Use This Template” button at the top right 
2. Click “Create a new repository”

![Use This Template Button](https://docs.github.com/assets/cb-77734/mw-1440/images/help/repository/use-this-template-button.webp)

From there you can input the relevant information for your new repository.  Be sure to give it a clear, brief description and use the appropriate naming convention depending on the purpose of the repository.  By default it should be “private” until ready to publish as public. 

### Proper repository naming structure

What is the purpose of your repository?  Depending on the purpose you will want to use one of the following standard naming conventions:

- *Infrastructure:* General-purpose code/toolsintended to be leveraged by other group members for their projects.  These should simply be named with a descriptive title `TITLE-OF-REPO`
- *Manuscripts:* Calculations, raw data, and data analysis for generating figures in publications should be named `manu-TITLE-OF-MANUSCRIPT`
  - The repository should be cited from the arxiv and published manuscript for future reference
  - When manuscript or arxiv are out (whichever first) the repository should be converted to a public repository (see [instructions for conversion to public repository](#Conversion-to-Public-Repository-and-Licensing)).  
- *Projects:*  If it is for a specific application or personal use (i.e. not a general use tool) then name it as `proj-DESCRIPTIVE-TITLE-OF-PROJECT`
  - The repo should be linked to from the project notes if they exist for future reference
- *Proposals:* Calculations, raw data, and data analysis for generating figures in proposal documents should be named `prop-NAME-OF-PROPOSAL`
  - You should link to this repository in the proposal notes for future reference

### Guidelines for brief description of your repository

Your repository should have a brief description.  This is important so that team members can easily scan through the groups repositories and understand what their purpose is.

The description should state succinctly what the purpose of the repository is.  

Examples:

- Simulates near fields (3D) and power transmission/reflection from nanoantennas on a substrate when excited by an ultrafast pulse.
- This repository provides all necessary code and data to produce the results shown in our publication arXiv:2009.06045 [physics.optics].

## Guidelines for a good README document with examples
A good README document should:

- Provide a brief paragraph at the top to describe the purpose of the repository.  What is it for?  Who is the intended user?
- Describe how to get the code running
  - How it should be properly installed
  - Needed dependencies/system requirements
    - If using python, at minimum, include a `requirements.txt` file which can be generated with `pip freeze > requirements.txt`
- Describe how to use the code
  - How to run it
  - What functions are provided along with detailed descriptions of how they work
- Describe any known issues with the code (assumptions, things that do not work, caveats)
- Discuss theory of the calculations where relevant (especially for numerical simulation tools), providing references to manuscripts and any included technical notes wherever relevant.
- Links to relevant documentation if it exists

Examples:
- [neuron](https://github.com/qnngroup/neuron)
- [mp_sf_cython](https://github.com/qnngroup/mp_sf_cython)

## Cloning your repo, pulling and pushing changes
In order to make changes to your newly-created repo, you will need a git client:
- git command-line tool (usually installed by default on linux, can be installed on Windows with git bash or CYGWIN/MINGW-W64)
- [GitHub Desktop](https://desktop.github.com/)
After generating a new git repository, clone it to modify it on your local machine, and use `git pull` and `git push` to keep the remote and local copies of the repository up-to-date
- Use `git pull` to incorporate remote changes (e.g. those added by another user) to your local copy.
- Use `git add` to add files to be staged for commit. The command `git add -A` will add all the files in your current working directory and subdirectories. Only use this if you have a .gitignore file set up.
  - A .gitignore file will specify all the files that would be ignored when doing `git add -A`. You can specify the full path of a specific file or the type of files you’d like to be ignored (e.g. *.png). This is a useful way to avoid having pushing heavy data files that result from simulations.
- Use `git commit -m “<message>”` to commit your changes. Make sure that your commit message is more specific than just “fixing bugs” or “adding files”. A good example might be
- Use `git push` to push local changes to allow other users to see the changes you’ve made. You must push your changes before you can pull changes that someone else made to the repo. If you both made changes, you will receive merge conflicts which are discussed in the advanced git section.

## Advanced git tutorials
[Github git guide](https://github.com/git-guides)
- Merge conflicts 
- Fork 
- Create a branch 
- Switch between branches
- [Rebasing and merging](https://www.atlassian.com/git/tutorials/merging-vs-rebasing) (TL;DR, when you want to incorporate new changes from `main` into your `feature` branch, `merge` main into your `feature` branch, don't `rebase` your `feature` branch)

## Conversion to Public Repository and Licensing
A license and approval from TLO is required for all publicly-facing repositories. Consult with your group leader and [MIT TLO](https://tlo.mit.edu/) to determine which license is appropriate and how to properly disclose release of your code.  
