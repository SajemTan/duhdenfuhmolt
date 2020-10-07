**WARNING: This code absolutely sux.**

# How to use

## Files

Create the file `Token` containing your API token.

Create the file `reactions` containing a list of reactions.

## Reactions

The `reactions` file is a yaml file containing an associative array of the form:

```yaml
"regex": "reaction text"
```

Whenever a message whose text matches `regex` is found, the bot will reply with
`reaction text`.

The example reaction file (`examples/reactions`) is an early version of the one
used by the bot. The file is automatically `.gitignore`'d for your convenience.
It's funner if the reactions are kept secret.

## Run on startup

Running this script on startup should be trivial but it ended up being harder
than I thought. It must start up after the network does. There is not an
obvious workaround for this. The best we can do is force it to retry.

See `examples/duhdenfuhmolt.service` for a `systemd` service that will run this
script on startup and keep trying every few seconds until it is stable. I
cannot promise that it's high quality. I don't use `systemd` and I especially
do not write custom services for it. Who cares. It's there if you want it.

Have fun with this degenerativity machine!
