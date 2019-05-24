.PHONY : deploy destroy

deploy :
	$(MAKE) -C terraformscripts/dev-327778747031/codepipeline

destroy :
	$(MAKE) -C terraformscripts/dev-327778747031/codepipeline destroy
