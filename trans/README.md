# Translate command by nim

It contains the translation command.

- This command uses the Microsoft Translator API.
- Enable the [Microsoft Translator](https://datamarket.azure.com/dataset/bing/microsofttranslator) in the Azure Marketplace, please [get a client id and secret](https://datamarket.azure.com/developer/applications).

## Usage

```
$ nim c trans.nim
$ ./trans "Thank you." -to:ja -from:en
```
