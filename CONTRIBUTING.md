## Contributing

[![Build Status](https://travis-ci.org/frederickk/orca.svg?branch=master)](https://travis-ci.org/frederickk/orca)


Contributions via github [pull requests](https://help.github.com/articles/about-pull-requests/) are more than welcome.


### Prerequisites

- [git](https://git-scm.com/) client (used for source version control).
- [github](https://github.com/) account (to contribute changes).
- [ssh](https://en.wikipedia.org/wiki/Secure_Shell) client (used to authenticate with github).


### Getting started

There are 2 main branches used for maintaining quality of experieece.

- [Primary](https://github.com/frederickk/orca/tree/primary) is the stable branch and also the branch thatis pulled in by users through [Maiden](https://monome.org/docs/norns/maiden/).
- [Dev](https://github.com/frederickk/orca/tree/dev) is the "bleeding edge" branch and should only be used by those that are helping debug, contributing, or those that like to live dangerously.


- ensure all the dependencies described in the previous section are installed.
- fork `https://github.com/frederickk/orca` into your own github account (more on forking
   [here](https://help.github.com/articles/fork-a-repo/)).
- if you haven't configured your machine with an ssh key that's known to github then follow
   these [directions](https://help.github.com/articles/generating-ssh-keys/).
- Clone your forked repo and navigate to a local directory to hold your sources.
```bash
$ git clone https://github.com/<your_name_here>/orca.git orca-dev
$ cd orca-dev
```
- Add remote to primary repository, so that you can `git fetch` and merge changes made there to your local fork
```
$ git remote add upstream https://github.com/frederickk/orca.git
```


### Writing code

To start working on a patch:

```bash
$ git fetch upstream
$ git checkout upstream/master -b name_of_your_branch
```

Start hacking away! And update your repo on Github as you work

```bash
$ git commit -a -m "<your brief but informative commit message>"`
$ git push origin name_of_your_branch`
```

### Creating a Pull Request (PR)

- go to [`https://github.com/frederickk/orca`](https://github.com/frederickk/orca)
   and click the "Compare & pull request" button.
- be sure and include a description of the proposed change and reference any
   related issues or folks; note that if the change is significant, consider
   opening a corresponding github [issue](https://help.github.com/articles/about-issues/)
   to discuss. (for some basic advice on writing a pr, see the github's
   [notes on writing a perfect pr](https://blog.github.com/2015-01-21-how-to-write-the-perfect-pull-request/).)

Once I've had a chance to review the code and test it I'll merge and et violà!