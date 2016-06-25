CHROME=google-chrome-beta

.PHONY: all
all: theme-work.crx.sig theme-personal.crx.sig theme-3rdparty.crx.sig theme-untrusted.crx.sig

.PHONY: clean
clean:
	rm -f *.pem

.PHONY: mrproper
mrproper:
	$(MAKE) clean
	rm -f *.crx *.crx.sig

theme-%.crx.sig: theme-%.crx
	gpg -b $<

.SECONDARY:
theme-%.crx: theme-%/manifest.json theme-%.pem
	google-chrome-beta --pack-extension=$(<D)  --pack-extension-key=$(<D).pem

%.pem: %.pem.gpg
	gpg -d $< > $@

.PHONY: publish
publish: all
	rm -rf .git/publish
	git branch -D publish || true
	git worktree add .git/publish
	cd .git/publish; git branch -D gh-pages || true
	cd .git/publish; git checkout --orphan gh-pages
	cd .git/publish; git rm -rf .; git clean -x -d -f
	cp *.crx *.crx.sig .git/publish/
	cd .git/publish; git add .; git commit -m "new version"
	#git push origin +gh-pages
