GNU Guix for High-Performance Computing
===========================================

[![pipeline status](https://guix.bordeaux.inria.fr/jobset/guix-hpc/badge.svg)](https://guix.bordeaux.inria.fr/jobset/guix-hpc) [![SWH](https://archive.softwareheritage.org/badge/origin/https://gitlab.inria.fr/guix-hpc/guix-hpc/)](https://archive.softwareheritage.org/browse/origin/https://gitlab.inria.fr/guix-hpc/guix-hpc/)

Hello!  This repository contains package recipes and extensions of the
[GNU Guix package manager](https://guix.gnu.org) for high-performance
computing (HPC).  It contains packages for HPC software
developed as used at [Inria](https://www.inria.fr/en) and elsewhere.

The goal is for most contributions to go upstream.  This repo acts as a
staging area or a place to store things not meant for public consumption
yet.

Please send inquiries to the [Guix-Science mailing
list](https://lists.gnu.org/mailman/listinfo/guix-science) or to
[Ludovic Courtès](mailto:ludovic.courtes@inria.fr).

## Getting started

All of this won’t be of any use to you until you have
[Guix](https://guix.gnu.org) on your system.  See the
[installation instructions](https://guix.gnu.org/manual/en/html_node/Binary-Installation.html).

If you’d like to use Guix on a cluster that doesn’t have it yet, stay
tuned, check out [these
instructions](https://guix.gnu.org/cookbook/en/html_node/Installing-Guix-on-a-Cluster.html).

## How does it work?

The package definitions in this repo _extend_ [those that come with
Guix](https://hpc.guix.info/browse).  To make them visible to the
`guix` command-line tools, create the `~/.config/guix/channels.scm` file
with the following snippet to request the `guix-hpc` _channel_:

```scheme
(cons (channel
        (name 'guix-hpc)
        (url "https://gitlab.inria.fr/guix-hpc/guix-hpc.git"))
      %default-channels)
```

That way, `guix pull` will systematically pull not only Guix, but also
Guix-HPC.

## Pre-built binaries

Pre-built binaries for Guix-HPC packages are served from
`https://guix.bordeaux.inria.fr`. To benefit from them, you must (1) add this
repository to the list of substitute-urls and (2) authorize the key associated
with this repository.  [As the manual
explains](https://guix.gnu.org/manual/en/html_node/Getting-Substitutes-from-Other-Servers.html),
it goes along these lines:

  1. Add `https://guix.bordeaux.inria.fr` to the `--substitute-urls`
     option [of
     `guix-daemon`](https://www.gnu.org/software/guix/manual/en/html_node/Invoking-guix_002ddaemon.html#daemon_002dsubstitute_002durls)
     or that [of client
     tools](https://www.gnu.org/software/guix/manual/en/html_node/Common-Build-Options.html#client_002dsubstitute_002durls).
     
     To enable it globally, you must modify the guix-daemon. How to do that
     depends how your services are handled on the system. If you are running
     guix on top of a foreign distribution (such as Debian, Ubuntu, ...), your
     system is likely to rely on systemd to handle services. In this case, you
     may enable the guix-daemon as follows and proceed to (2):
	 
	 ```
	 $EDITOR /etc/systemd/system/guix-daemon.service

	   … add ‘--substitute-urls='https://ci.guix.gnu.org https://guix.bordeaux.inria.fr'’
       to the ‘guix-daemon’ command line.
	  
     systemctl daemon-reload
	 systemctl restart guix-daemon.service
	 ```
     
     On Guix System itself, services are handled by the Shepherd.  You can for
     instance declare a customized list of services `%my-service` (here derived
     from `%desktop-services` but you may want to derive it from `%base-services` on
     a server-only system) in your `/etc/config.scm` configuration file:
     
     ```scheme
     (define %my-services
	   (modify-services %desktop-services
		 (guix-service-type config =>
		  (guix-configuration
		   (inherit config)
		   (substitute-urls '("https://ci.guix.gnu.org"
                              "https://guix.bordeaux.inria.fr"))))))
     ```

     These customized services can then be used in the declaration of your
     operating system further in the same /etc/config.scm configuration file:
     
     ```scheme
     (operating-system
      ;; ...
      (services %my-services)
      ;; ...
     )
     ```
     
     In practice, instead of declaring your services with this customized list
     only, you will likely append typical additional services you use to it,
     such as in the following example:
     
     ```scheme
     (services
      (append
      (list (service gnome-desktop-service-type)
	        (service openssh-service-type)
            (set-xorg-configuration
             (xorg-configuration
              (keyboard-layout keyboard-layout)))
            ;; ...
            (service cups-service-type))
      %my-services))
     ```

     Once the `/etc/config.scm` has been set up, the system can be reconfigured:
     ```
     sudo guix system reconfigure /etc/config.scm
     ```
     
     The machine does not need to be globally restarted, it is sufficient to restart the service:
     ```
     sudo herd restart guix-daemon
     ```

     The correctness of the set up can then be checked with the ```ps aux | grep
     guix-daemon``` command.


  2. [Authorize](https://www.gnu.org/software/guix/manual/en/html_node/Substitute-Server-Authorization.html)
     the key used to sign substitutes:

	 ```
	 (public-key
	  (ecc
	   (curve Ed25519)
	   (q #89FBA276A976A8DE2A69774771A92C8C879E0F24614AAAAE23119608707B3F06#)))
	 ```
	 
	 Typically, assuming the key above is stored in `key.txt`, run as root:
	 
	 ```
	 guix archive --authorize < key.txt
	 ```

Enjoy!

## Continuous integration

This channel is [continuously
built](https://guix.bordeaux.inria.fr/jobset/guix-hpc) on our instance
of [Cuirass](https://guix.gnu.org/en/cuirass/), the Guix-based
continuous integration tool.  Each commit on either the `guix-hpc` or
the `guix` channel triggers a rebuild, if needed, of the `guix-hpc`
packages.

## Hacking on Guix-HPC

When working on packages of the `guix-hpc` channel, you'll need to clone
the `guix-hpc` repository:

```
cd src
git clone https://gitlab.inria.fr/guix-hpc/guix-hpc.git
```

From then on, you can edit package definitions, and then try them out by
passing the location of the checkout using the `-L` flag to `guix build`
and other command-line tools, as in this example:

```
guix build -L ~/src/guix-hpc starpu
```

When you’re satisfied with your changes, push them—your changes are now
just a `guix pull` away for users of your channel!

## Guidelines for modifications

New modules defining packages should be located in `guix-hpc/packages`
thus belonging to the Guile `(guix-hpc packages)` namespace.

New packages should be added to the relevant module in
`guix-hpc/packages`. A new module can be created if needed.

Note that there is an ongoing effort for moving the old modules to the
new namespace, so not all the modules and packages follow the
guidelines stated above.

## More information

The Guix manual contains useful information:

  * on [getting
    started](https://guix.gnu.org/manual/en/html_node/Getting-Started.html);
  * on the [channels
    mechanism](https://www.gnu.org/software/guix/manual/en/html_node/Channels.html),
    which allows you to pull in `guix-hpc` packages in addition to those
    provided by Guix;
  * on
    [the `GUIX_PACKAGE_PATH` environment variable](https://guix.gnu.org/manual/en/html_node/Package-Modules.html#index-GUIX_005fPACKAGE_005fPATH),
    which allows you to extend the set of packages visible to `guix`.

Check out the [Guix-HPC web site](https://hpc.guix.info/blog) for more
info.
