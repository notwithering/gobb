# gobb - good ol' bash bundler

a bash bundler to merge multiple sourced scripts into one script

## usage

<details>
<summary>main.sh</summary>
<pre>
#!/bin/bash
source ./hello.sh
hello
</pre>
</details>

<details>
<summary>hello.sh</summary>
<pre>
#!/bin/bash
hello() {
	echo "hello"
}
</pre>
</details>

```bash
gobb main.sh
```

<details>
<summary>ouput (one unified script)</summary>
<pre>
#!/bin/bash

hello() {
    echo "hello"
}

hello
</pre>
</details>
