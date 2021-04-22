## aspis
aspis is an encryption filter gem that encrypts anything it receives from stdin and sends the ciphertext to stdout. 
It relies on Libsodium (via RbNaCl) for its cryptographic primitives. Output is in JSON format.

-  Cipher: XSalsa20-Poly1305
-  Public Keys: Curve25519
-  Key exchange: X25519 (static-static Diffie Hellman)
-  Password-based key derivation: Argon2i
-  Nonces are randomly generated.

### Setup
aspis requires Libsodium and the Ruby gem RbNaCl.

To use, install the gem:
```
gem install aspis
```

Or to build and install from Github:
```
$ git clone https://gitlab.com/jsaf/aspis
$ cd aspis
# bundle exec rake install
```

### Usage
Basic syntax:
```
aspis [-n] [-o] [-m] -e|-d|-g
```
The flags -e or -d tell aspis to encrypt or decrypt respectively. 
The -g flag creates a new keypair in the ~/.aspis directory, creating that directory if necessary.

If used with the -n option, aspis will look for the password in the environment
variable ASPIS_PASS rather than asking for it on the command line. This is useful if
you want to use aspis in a script, but environment variables are not as secure as they may seem.
It is best to disable your shell's history if using this option to prevent something like 
```
export ASPIS_PASS=p@ssw0rd
```
from appearing in the shell's history file. 

To manually tweak Argon2i's CPU ops and memory parameters, use the -o and -m 
options. Memory is specified in MiB.

Simple example of encrypting a message with a password-derived key:
```
echo "hello" | aspis -e
```
Encrypt file.pdf and write the output to file.enc:
```
aspis -e file.pdf > file.enc
```
Encrypt a file piped via cat(1) and send it over the network with netcat:
```
cat file.pdf | aspis -e | nc 192.168.1.1 4444
```
Alice encrypts a file for Bob, using his public key and her default private key located in ~/.aspis:
```
aspis -e -p bob-pubkey message-for-bob.txt > message-for-bob.enc
```
Bob would decrypt the above file like so:
```
aspis -d -p alice-pubkey message-for-bob.enc > message-for-bob.txt
```
To send an encrypted email to Bob, you can use aspis with mutt like so:
```
echo "top secret message for Bob" | aspis -e -p bob-pubkey | mutt -s "Urgent, read immediately" bob@mailercorp.com
```
Bob would then open the email in mutt, and press "|" to pipe the message to an external command. To decrypt, he would
grep for the aspis portion of the email, then pipe that into aspis:
```
grep ciphertext | aspis -d -p alice-pubkey
```
The now decrypted message body will be displayed.

### Security considerations
aspis uses the NaCl crypto_box function underneath (via Libsodium) for its public key cryptography. 
Key exchanges in asymmetric mode are static-static Diffie Hellman, which means that the shared key between 2 parties will be the same for all
of their communication. One desirable property of static-static DH (or "full static" as it is sometimes known) is that it provides
mutual authentication. Once Alice and Bob have each other's public keys, they can be sure that future messages 1.) can only be decrypted by Alice or Bob, and 2.) are actually from Alice or Bob.

The unfortunate part of this scheme is that their shared key is always the same, until one of them changes their long-term keys. This means that if an 
attacker is able to compromise either Alice or Bob's key, it exposes all past messages between them. A scheme that provides forward secrecy would only expose messages encrypted with the compromised key, not all messages. However, this is harder to do for the asynchronous communication for which aspis is likely to be used.


I took the view that key impersonation is easier for an attacker and thus more likely than key compromise, and chose a scheme that provides mutual authentication to counter this. Yes, I am aware of its drawbacks. 

Consult the NaCl paper for formal discussion of the cryptography used in aspis: https://cr.yp.to/highspeed/naclcrypto-20090310.pdf
