class videoactor2 extends kactorspawnable;

DefaultProperties
{
	begin object name=staticmeshcomponent0
		StaticMesh=StaticMesh'demo_asset.Whole_mirror_Glass'
		materials(0)= Material'demo_asset.AvatarMovie'
		scale3d = (x=60.0, y=1.0, z=25.0)
		LightEnvironment=MyLightEnvironment
		BlockRigidBody=false
		BlockZeroExtent=false
		end object

	bnodelete=false
	bWakeOnLevelStart=true
	Physics=PHYS_none


}
