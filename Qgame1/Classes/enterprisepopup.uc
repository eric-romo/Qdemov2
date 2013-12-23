class enterprisepopup extends kactorspawnable;

var repnotify int popupnumber;
var array<material> popups;
var texturemovie popupmovie;

replication
	{
		if (bnetdirty)
			popupnumber;
	}

simulated event replicatedevent (name varname)
{
	if (varname == 'popupnumber')
		changepopup();

}

simulated function changepopup()
{
	staticmeshcomponent.SetMaterial(0, popups[popupnumber]);
	popupmovie.Play();
}



DefaultProperties
{
	popups[0]=Material'demo_asset.ent_popup1_Mat';
	popups[1]=Material'demo_asset.ent_popup2_Mat';
	popups[2]=Material'demo_asset.ent_popup3_Mat';
	popups[3]=Material'testpackage1.ent_popup_video_mat';
	popupmovie = TextureMovie'testpackage1.ent_popup_video';

	popupnumber = 8;

begin object name=staticmeshcomponent0
		StaticMesh=StaticMesh'demo_asset.SM_popup_box'
		materials(0)= Material'testpackage1.Materials.Lens'
		//scale3d = (x=0.3, y=0.15, z=0.25)
		LightEnvironment=MyLightEnvironment
		BlockRigidBody=false
		BlockZeroExtent=false
		end object

	bnodelete=false
	bWakeOnLevelStart=true
	Physics=PHYS_none
	balwaysrelevant = true

}
