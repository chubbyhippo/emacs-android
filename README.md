# emacs-android

## install early-init.el

```shell
mkdir -p ~/.emacs.d && curl -fsSL https://raw.githubusercontent.com/chubbyhippo/emacs-android/refs/heads/main/.emacs.d/early-init.el -o ~/.emacs.d/early-init.el
```

## get signed termux

```shell
curl -fsSL https://raw.githubusercontent.com/chubbyhippo/emacs-android/refs/heads/main/signedtermux.sh | sh
```

## get emacs.keystore

https://github.com/emacs-mirror/emacs/raw/refs/heads/master/java/emacs.keystore

## get termux

https://f-droid.org/repo/com.termux_1022.apk

## sign termux

```shell
apksigner sign --v2-signing-enabled --ks emacs.keystore -debuggable-apk-permitted --ks-pass pass:emacs1 com.termux_1022.apk
```

## get emacs

https://f-droid.org/repo/org.gnu.emacs_310100002.apk

## get signed emacs

Requires `apktool` and `apksigner` on PATH. Run it after `signedtermux.sh`, because Emacs must be signed with the same keystore as Termux to share its user ID.

```shell
curl -fsSL https://raw.githubusercontent.com/chubbyhippo/emacs-android/refs/heads/main/signedemacs.sh | sh
```

The script adds `android:sharedUserId="com.termux"` to the Emacs manifest, adds the `shared_user_label` string, rebuilds the APK as `emacs_for_termux.apk`, and signs it with `emacs.keystore`. 

## references

https://github.com/johanwiden/termux-for-android-emacs  
https://marek-g.github.io/posts/tips_and_tricks/emacs_on_android/  
https://snow-dev.com/posts/Emacs/bring_your_emacs_to_android