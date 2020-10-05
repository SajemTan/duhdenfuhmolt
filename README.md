**WARNING: This code absolutely sux.**

# How to use

Create the file `Token` containing your API token.

Create the file `reactions` containing a yaml associative array with:

```yaml "regex": "reaction text" ```

Whenever a message whose text matches `regex` is found, the bot will reply
with `reaction text`.

The example reaction file (`examples/reactions`) is an early version of the
one used by the bot. The file is automatically `.gitignore`'d for your
convenience. It's funner if the reactions are kept secret.

Have fun with this degenerativity machine!
