# IIS HTTPS Certificate Troubleshooting

## Error

If you see:

`ERR_CERT_COMMON_NAME_INVALID`

it usually means IIS is using a certificate that does not match the URL hostname.

Example:

`https://localhost`

must use a certificate containing:

`localhost`

## 1. Check available certificates

Run:

```powershell
Get-ChildItem Cert:\LocalMachine\My | Select-Object Subject,DnsNameList,Thumbprint,HasPrivateKey
```

Find the certificate matching your hostname.

## 2. Check the certificate used by IIS/HTTP.sys

Run:

```powershell
netsh http show sslcert
```

Check `Certificate Hash` for your HTTPS port.

Compare it with the certificate `Thumbprint` from step 1.

## 3. If the certificate is wrong

Delete the existing binding:

```powershell
netsh http delete sslcert ipport=[::]:443
```

Add the correct certificate:

```powershell
netsh http add sslcert ipport=[::]:443 certhash=YOUR_THUMBPRINT appid="{YOUR_APP_ID}" certstorename=MY
```

Then restart IIS:

```powershell
iisreset
```

## 4. Test

Open:

`https://localhost`

The certificate hostname must match the URL hostname.

### Quick rule

**URL hostname = Certificate hostname**

`https://localhost` → certificate contains `localhost`

`https://myserver.local` → certificate contains `myserver.local`

`ERR_CERT_COMMON_NAME_INVALID` → first check the certificate bound to the HTTPS port.
