
<img width="716" height="854" alt="image" src="https://github.com/user-attachments/assets/ba7db517-0bfa-4f50-9944-c4b0054a4875" />
<img width="812" height="808" alt="image" src="https://github.com/user-attachments/assets/074849a4-d82e-4103-a281-4f664d319d02" />
<img width="841" height="397" alt="image" src="https://github.com/user-attachments/assets/38c8ad6e-875f-4f9b-9b17-0f1397284c2c" />
<img width="794" height="219" alt="image" src="https://github.com/user-attachments/assets/b376b78d-9101-43e7-9784-a4c8e6d53f07" />

# Tool suite
This is the personal innocent tool suite
It's connected to an agent that will notify in case of vulnerability discovery.

# Getsub.sh
Getsub it is a tool that iterate over a list of given domains taken from the whole bug bounty global scope.
https://github.com/arkadiyt/bounty-targets-data/blob/main/data/wildcards.txt

# Ghostsub.sh
This tool it's the main heart, it iterates over all the subdomains discovered, sending request with the scope of identifying takeover fingerprints taken my 
[CanITakeOverXYZ](https://github.com/EdOverflow/can-i-take-over-xyz) list.
It also resolve CNAMES in order to identify CNAMES fingerprint or error.


# Notifications
simply edit the provider-config.yaml with your discord web hook and give it a name.

#In case something mess up
[Subzy](https://github.com/PentestPad/subzy/blob/master/runner/download.go)
