To make this gogs lab more portable, I've left here the ssh-keys and config needed to make commits into the repo. This is ok, for a lab - dont do this out-in-the-wild :)


# How to apply this to a *new repo* of user1

```
# 1st-time clone
cd <<same-dir-that-also-contains_subdir user1.ssh.config/ >>
GIT_SSH_COMMAND="ssh -F $PWD/user1.ssh.config/config" git clone ssh://git@172.17.0.1:10022/user1/gitopsgitrepo.git
cd gitopsgitrepo
git config core.sshCommand "ssh -F $PWD/../user1.ssh.config/config"

# And from now on, the local repo is configured to load the user1.ssh.config/config which will use the prepared keys
# So from now on, normal workflow becomes
cd gitopsgitrepo
git remote show origin
git add ...
git commit ...
git push ...


```

