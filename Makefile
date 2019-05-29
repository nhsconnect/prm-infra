.PHONY : deploy destroy

deploy :
	$(MAKE) -C terraformscripts/dev-327778747031/assume_role
	$(MAKE) -C terraformscripts/dev-327778747031/codepipeline

destroy :
	$(MAKE) -C terraformscripts/dev-327778747031/codepipeline destroy
	$(MAKE) -C terraformscripts/dev-327778747031/assume_role destroy
