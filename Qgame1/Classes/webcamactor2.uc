class webcamactor2 extends kactorspawnable;

DefaultProperties
{
	begin object name=staticmeshcomponent0
		StaticMesh=StaticMesh'demo_asset.Whole_mirror_Glass'
		materials(0)= Material'demo_asset.webcam1_mat'
		scale3d = (x=3.0, y=1.0, z=3.0)
		LightEnvironment=MyLightEnvironment
		BlockRigidBody=false
		BlockZeroExtent=false
		end object

	bnodelete=false
	bWakeOnLevelStart=true
	Physics=PHYS_none


}
