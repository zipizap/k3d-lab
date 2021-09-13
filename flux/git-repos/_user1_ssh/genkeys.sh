if [[ ! -r ./id_ed25519 ]] 
then 
  ssh-keygen -N '' -t ed25519 -f ./id_ed25519
else
  echo "key ./id_ed25519 already exists - skipping"
fi
