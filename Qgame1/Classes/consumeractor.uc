class consumeractor extends kactorspawnable;

var repnotify int consumernumber;
var array<staticmesh> consumermeshes;
var bool bwastouched;
var array<string> line1, line2, line3;

replication
	{
		if (bnetdirty)
			consumernumber;
	}

simulated event replicatedevent (name varname)
{
	if (varname == 'consumernumber')
		changeconsumermesh();

}

simulated function changeconsumermesh()
{
	staticmeshcomponent.SetStaticMesh(consumermeshes[consumernumber]);
	
}

simulated event touch(actor other, PrimitiveComponent OtherComp, Object.Vector HitLocation, Object.Vector HitNormal)
{

	bwastouched = true;
	super.Touch(other, othercomp, hitlocation, hitnormal);

}
DefaultProperties
{
	consumermeshes[0] = StaticMesh'Demo_Assets.static_meshes.SM_Canon_EOS_5D';
	consumermeshes[1] = StaticMesh'Demo_Assets.static_meshes.SM_Canon_EOS_Rebel';
	consumermeshes[2] = StaticMesh'Demo_Assets.static_meshes.SM_Nikon_D7000';
	consumernumber = 8
	bwastouched = false

	line1[0] = "Canon EOS 5D"
	line2[0] = "22.3MP"
	line3[0] = "$2,649.00"

	line1[1] = "Cannon EOS Rebel T3i"
	line2[1] = "18.0MP"
	line3[1] = "$499.00"

	line1[2] = "Nikon D7000"
	line2[2] = "16.2MP"
	line3[2] = "$994.00"

	begin object name=staticmeshcomponent0
		StaticMesh=StaticMesh'demo_asset.Master_Cube'
		end object

	CollisionComponent=StaticMeshComponent0
	
	bnodelete=false
	bWakeOnLevelStart=true
	

}
