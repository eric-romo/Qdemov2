class presentationactor extends kactorspawnable;

var repnotify int slidenumber;
var textureflipbook presentation_texture;


replication
	{
		if (bnetdirty)
			slidenumber;
	}

simulated event replicatedevent (name varname)
{
	if (varname == 'slidenumber')
		changeslide();

	super.ReplicatedEvent(varname);
}

simulated function changeslide()
{
	local int slidenumber_row, slidenumber_column;


	if (slidenumber == 1)
		{slidenumber_row = 0;
		 slidenumber_column = 0;}
		
		if (slidenumber == 2)
		{slidenumber_row = 0;
		 slidenumber_column = 1;}

		 if (slidenumber == 3)
		 {slidenumber_row = 1;
		 slidenumber_column = 0;}

		 if (slidenumber ==4)
		 {slidenumber_row = 1;
		 slidenumber_column = 1;}
		
		presentation_texture.SetCurrentFrame(slidenumber_row, slidenumber_column);


}


DefaultProperties
{

	presentation_texture = TextureFlipBook'demo_asset.slideshow1';

		begin object name=staticmeshcomponent0
		StaticMesh=StaticMesh'demo_asset.Whole_mirror_Glass'
		materials(0)= Material'demo_asset.slideshow1_mat'
		scale3d = (x=15.0, y=5.0, z=5.0)
		LightEnvironment=MyLightEnvironment
		BlockRigidBody=false
		BlockZeroExtent=false
		end object

	
	bnodelete=false
	bWakeOnLevelStart=true
	Physics=PHYS_none

	slidenumber =-1

}
