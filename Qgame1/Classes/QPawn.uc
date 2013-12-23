class QPawn extends UTPawn
	config(Game)
	notplaceable;



var SkelControlSingleBone RightHand, LeftHand, head, spine1, hips1;
var SkelControlLimb RightArm, LeftArm;

var repnotify vector RightArmLocation, LeftArmLocation, SocketLocation,  headposition;
var repnotify bool blimbsmoving;
var repnotify rotator righthandrotation, headrotation, lefthandrotation;
var repnotify float pawn_initial_yaw;


//movie variables
var videoactor movie1;
var videoactor2 movie2;
var texturemovie movie_texture_var2;
var texturemovie movie_texture_var;
var repnotify bool bmovie1playing, bmovie2playing;

//webcam variables
var webcamactor1 webcam1;
var webcamactor2 webcam2;
var texturemovie webcam1_texture, webcam2_texture;
var repnotify bool bwebcamsplaying;

var mirroractor themirror;

replication
	{
		if (bnetdirty)
			bmovie1playing, bmovie2playing, bwebcamsplaying, blimbsmoving, righthandrotation, 
				rightarmlocation, socketlocation, LeftArmLocation, headposition, headrotation, lefthandrotation, pawn_initial_yaw;
	}

simulated event ReplicatedEvent(name VarName)
{
   
    if (VarName == 'blimbsmoving')
    {
    	armsandheadmove();
    }
    if (varname == 'bmovie1playing')
    {
		playpausemovie();
	}
	if (varname == 'bmovie2playing')
    {
		playpausemovie2();
	}
	if (varname == 'bwebcamsplaying')
    {
		playpausewebcams();
	}
	Super.ReplicatedEvent(VarName);
}


simulated function PostBeginPlay()
{
	Super.PostBeginPlay();


	if (!bDeleteMe)
	{
		if (Mesh != None)
		{
			BaseTranslationOffset = Mesh.Translation.Z;
			CrouchTranslationOffset = Mesh.Translation.Z + CylinderComponent.CollisionHeight - CrouchHeight;
			OverlayMesh.SetParentAnimComponent(Mesh);
		}
	}


}

simulated function movie_create()
{
	local vector spawnlocation;
	local rotator spawnrotation;
	
	if (role<role_authority)
		server_movie_create();
	else
	{
	spawnlocation.X = -925; //Location.X - 175;
	spawnlocation.Y = 50; //Location.Y + 275;
	spawnlocation.Z = 25; //Location.Z - 25;
	spawnrotation.yaw = 32000;
	
		if (movie1 == none)
		{
		movie1 = spawn(class'videoactor',,,spawnlocation,spawnrotation);
		bmovie1playing = true;
		}
		else
		{
			movie1.Destroy();
			movie1 = none;
			bmovie1playing = false;
		}
	playpausemovie();
	}
}

reliable server function server_movie_create()
{

	local vector spawnlocation;
	local rotator spawnrotation;
	
	spawnlocation.X = -925; //Location.X - 175;
	spawnlocation.Y = 50; //Location.Y + 275;
	spawnlocation.Z = 25; //Location.Z - 25;
	spawnrotation.yaw = 32000;
	

	if (movie1 == none)
		{
		movie1 = spawn(class'videoactor',,,spawnlocation,spawnrotation);
		bmovie1playing = true;
		}
		else
		{
			movie1.Destroy();
			movie1 = none;
			bmovie1playing = false;
		}
	playpausemovie();

}

simulated function toggle_movie()
{
	if (role<role_authority)
		server_toggle_movie();
	else
	{
	bmovie1playing = !bmovie1playing;
	playpausemovie();
	}
}

reliable server function server_toggle_movie()
{
	bmovie1playing =!bmovie1playing;
	playpausemovie();
}

simulated function playpausemovie()
{
	if (bmovie1playing)
		movie_texture_var.Play();
	else
		movie_texture_var.Pause();
}

simulated function toggle_movie2()
{
	if (role<role_authority)
		server_toggle_movie2();
	else
	{
	bmovie2playing = !bmovie2playing;
	playpausemovie2();
	}
}

reliable server function server_toggle_movie2()
{
	bmovie2playing =!bmovie2playing;
	playpausemovie2();
}

simulated function playpausemovie2()
{
	if (bmovie2playing)
		movie_texture_var2.Play();
	else
		movie_texture_var2.Pause();
}

simulated function switchmovie()
{	

	server_destroy_movie1();
	server_add_movie2();

}

reliable server function server_destroy_movie1()
{
		bmovie1playing = false;
		playpausemovie();
		movie1.Destroy();
		movie1 = none;

}


reliable server function server_add_movie2()
{
	local vector spawnlocation;
	local rotator spawnrotation;
	
	spawnlocation.X = -1175; //Location.X - 175;
	spawnlocation.Y = 165; //Location.Y + 275;
	spawnlocation.Z = -110; //Location.Z - 25;
	spawnrotation.yaw = 32000;
	
	
	if (movie2 == none)
		{
		movie2 = spawn(class'videoactor2',,,spawnlocation,spawnrotation);
		bmovie2playing = true;
		playpausemovie2();
		}
		else
		{
			movie2.Destroy();
			movie2 = none;
			bmovie2playing = false;
			playpausemovie2();
		}

}

simulated function mirror_create()
{

	local vector spawnlocation;
	local rotator spawnrotation;
	
	if (role<role_authority)
		server_mirror_create();
	else
	{

		spawnlocation.X = -670;
		spawnlocation.Y = -377; 
		spawnlocation.Z = 25; 

		spawnrotation.yaw = 0;
	
		if (themirror != none)
		{	
			themirror.Destroy();
			themirror = none;
		}
		else
		{   
			themirror = spawn(class'mirroractor',,,spawnlocation,spawnrotation);
		}
	}

}

reliable server function server_mirror_create()
{

	local vector spawnlocation;
	local rotator spawnrotation;

	spawnlocation.X = -670;
	spawnlocation.Y = -377; 
	spawnlocation.Z = 25; 

	spawnrotation.yaw = 0;
	
	if (themirror != none)
	{	
		themirror.Destroy();
		themirror = none;
	}
	else
	{   
		themirror = spawn(class'mirroractor',,,spawnlocation,spawnrotation);
	}

}


reliable server function server_add_webcams()
{
	local vector spawnlocation;
	local rotator spawnrotation;
	
	spawnlocation.X = -620;
	spawnlocation.Y = -377; 
	spawnlocation.Z = 50; 
	spawnrotation.yaw = 0;
	
	
	if (webcam1 == none)
		{
		webcam1 = spawn(class'webcamactor1',,,spawnlocation,spawnrotation);

		spawnlocation.X = -570;
		spawnlocation.Y = -155; 
		spawnlocation.Z = 50; 
		spawnrotation.yaw = 20000;

		webcam2 = spawn(class'webcamactor2',,,spawnlocation,spawnrotation);

		bwebcamsplaying = true;
		webcam1_texture.Play();
		webcam2_texture.Play();
		
		playpausewebcams();
		}
		else
		{
			webcam1.Destroy();
			webcam2.Destroy();
			webcam1=none;
			webcam2 = none;
			bwebcamsplaying = false;
			webcam1_texture.Pause();
			webcam2_texture.Pause();
			
			playpausewebcams();
		}

}

simulated function playpausewebcams()
{
	if (bwebcamsplaying)
	{
			webcam1_texture.Play();
			webcam2_texture.Play();	
	}
	else
	{
			webcam1_texture.Pause();
			webcam2_texture.Pause();	
	}
}

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	super.PostInitAnimTree(SkelComp);
	
	
	if (skelcomp == mesh)
	{
	RightArm = SkelControlLimb(mesh.FindSkelControl('RightForeArm'));
	LeftArm = SkelControlLimb(mesh.FindSkelControl('LeftForeArm'));

	RightHand = SkelControlSingleBone(mesh.FindSkelControl('RightHand'));
	LeftHand = SkelControlSingleBone(mesh.FindSkelControl('LeftHand'));
	head = skelcontrolsinglebone(mesh.FindSkelControl('HeadControl'));
	spine1 = skelcontrolsinglebone(mesh.FindSkelControl('spineturn1'));
	hips1 = skelcontrolsinglebone(mesh.FindSkelControl('hips1'));
	}
}


simulated event TickSpecial(float DeltaTime)
{
	
	super.TickSpecial(DeltaTime);
//	armsandheadmove();  //putting this in here seems to increase body movement...not sure if I want this

}





simulated function armsandheadmove()
{
	local vector jointdirection, jointdirectionL;
	//local float current_yaw;

//	current_yaw = headrotation.Yaw;

	//JointDirection = vect(-50,0,-50);  //uncomment for UDK skel
	//jointdirectionL = vect(-50,0,50); //uncomment for UDK skel
	jointdirectionL = vect(-50,0,-50);
	JointDirection = vect(50,0,-50);
	
		RightHand.BoneRotation = righthandrotation;
		LeftHand.BoneRotation = lefthandrotation;
		//lefthand.BoneRotation.Roll = lefthand.BoneRotation.Roll + 32750;  //left hand axes are rotated 180deg //uncomment for UDK skel
		righthand.BoneRotation.yaw = righthand.BoneRotation.yaw + 32750;    //remove for UDK skel
		righthand.BoneRotation.roll = -righthand.BoneRotation.roll; //remove for UDK skel
		righthand.BoneRotation.Pitch = -righthand.BoneRotation.Pitch;   //remove for UDK skel

		if(bIsCrouched) RightArmLocation.Z -= CrouchHeight * 0.5;
		
		RightArm.EffectorLocation = RightArmLocation + Location;
		Mesh.GetSocketWorldLocationAndRotation('WeaponPoint',SocketLocation);
		RightArm.JointTargetLocation = TransformVectorByRotation(RightHand.BoneRotation, JointDirection) + SocketLocation;

		if(bIsCrouched) LeftArmLocation.Z -= CrouchHeight * 0.5;
		LeftArm.EffectorLocation = LeftArmLocation + Location;
		Mesh.GetSocketWorldLocationAndRotation('DualWeaponPoint',SocketLocation);
		LeftArm.JointTargetLocation = TransformVectorByRotation(LeftHand.BoneRotation, JointDirectionL) + SocketLocation;			
		
		//head.BoneRotation = headrotation - Rotation;
		head.BoneRotation.Pitch = headrotation.Roll;
		head.BoneRotation.Roll = -headrotation.Pitch;
		head.BoneRotation.Yaw = headrotation.Yaw + pawn_initial_yaw;

		head.BoneRotation.Roll = head.BoneRotation.Roll +16375;
		head.BoneRotation.Yaw = head.BoneRotation.Yaw - 16375;

		spine1.BoneRotation.Roll = rotation.roll + 16375;
		hips1.BoneRotation.Roll = rotation.Roll + 16375;

		spine1.BoneRotation.Yaw = headrotation.Yaw - 16384 + pawn_initial_yaw;
		hips1.bonerotation.yaw = headrotation.Yaw - 16384 + pawn_initial_yaw;

	/*
		if (pawn_initial_yaw > 16000 && current_yaw < 0)
		{   current_yaw = current_yaw + (2 * 32768);
			spine1.Bonerotation.yaw = ( pawn_initial_yaw + current_yaw  ) / 2 -  16384;
			hips1.BoneRotation.Yaw = ( 3* pawn_initial_yaw + current_yaw  ) / 4 -  16384;
		}
		else
		{

		if (current_yaw  < 32768 && current_yaw  > -32768)
		{
			spine1.Bonerotation.yaw = ( pawn_initial_yaw + current_yaw  ) / 2 -  16384;
			hips1.BoneRotation.Yaw = ( 3*pawn_initial_yaw + rotation.yaw ) /4   -  16384;
		}
		else
		{   
			if (current_yaw > 32768)
			{   spine1.BoneRotation.Yaw = ( pawn_initial_yaw + current_yaw  - (2 * 32768)) / 2 -  16384;
				hips1.BoneRotation.Yaw = ( 3*pawn_initial_yaw + rotation.yaw - (2 * 32768)) /4   -  16384;
			}
			else
			{
				spine1.BoneRotation.Yaw = ( pawn_initial_yaw - (2 * 32768) - current_yaw  ) / 2 -  16384;
				hips1.BoneRotation.Yaw = ( pawn_initial_yaw - (2 * 32768) - current_yaw  ) / 2 -  16384;
				hips1.BoneRotation.Yaw = ( 3*pawn_initial_yaw - (2 * 32768) - rotation.yaw ) /4   -  16384;
			
			}
		}
		}
	*/
}


// this runs on the client that runs the command, as well as being called from the server function below
simulated function ToggleBool()
{
    blimbsmoving = !blimbsmoving;
    armsandheadmove();
    if(Role < ROLE_Authority)
        ServerToggleBool(rightarmlocation, socketlocation, righthandrotation, leftarmlocation, headposition, headrotation, lefthandrotation, pawn_initial_yaw);
	
}

// this is called on the server, and toggles it on the server side.  the replication code automatically handles sending it to everyone that
// has a copy of this object
reliable server function ServerToggleBool(vector s_RightArmLocation, vector s_SocketLocation, rotator s_righthandrotation, vector s_LeftArmLocation, vector s_headposition, rotator s_headrotation, rotator s_lefthandrotation, float s_pawn_initial_yaw)
{
 
    blimbsmoving = !blimbsmoving;
	rightarmlocation = s_rightarmlocation;
	socketlocation = s_socketlocation;
	righthandrotation = s_righthandrotation;
	leftarmlocation = s_leftarmlocation;
	headposition = s_headposition;
	headrotation = s_headrotation;
	lefthandrotation = s_lefthandrotation;
	pawn_initial_yaw = s_pawn_initial_yaw;
	armsandheadmove();
}

//end hydra arm motion code

simulated event destroyed()
{
	super.destroyed();
	
	RightArm = none;
	LeftArm = none;
	RightHand = none;
	LeftHand = none;
	head = none;
	spine1 = none;
	hips1 = none;
	movie1 = none;
	movie2 = none;
}

DefaultProperties
{
	
	movie_texture_var = TextureMovie'demo_asset.BigGame2013Highlights';
	bmovie1playing = false;
	movie_texture_var2 = TextureMovie'demo_asset.AvatarMovieTrailer';

	webcam1_texture = TextureMovie'demo_asset.webcam1';
	webcam2_texture = TextureMovie'demo_asset.webcam2';
	bwebcamsplaying = false;

	blimbsmoving = false
	
	bScriptTickSpecial = true
	
	Begin Object Name=MyLightEnvironment
		bSynthesizeSHLight=TRUE
		bIsCharacterLightEnvironment=TRUE
		bUseBooleanEnvironmentShadowing=FALSE
		InvisibleUpdateTime=1
		MinTimeBetweenFullUpdates=.2
	End Object
	Components.Add(MyLightEnvironment)
	
	Components.Remove(WPawnSkeletalMeshComponent)
	Begin Object Name=WPawnSkeletalMeshComponent
		AnimTreeTemplate=AnimTree'testpackage1.avatars.mixamo_animtree'
		//AnimTreeTemplate=AnimTree'demo_asset.HX_FreeArms_3'  //uncomment for UDK skel
		bCacheAnimSequenceNodes=FALSE
		AlwaysLoadOnClient=true
		AlwaysLoadOnServer=true
		CastShadow=true
		BlockRigidBody=TRUE
		bUpdateSkelWhenNotRendered=true
		bIgnoreControllersWhenNotRendered=false //was true
		bUpdateKinematicBonesFromAnimation=true
		bCastDynamicShadow=true
		RBChannel=RBCC_Untitled3
		RBCollideWithChannels=(Untitled3=true)
		LightEnvironment=MyLightEnvironment
		bOverrideAttachmentOwnerVisibility=true
		bAcceptsDynamicDecals=FALSE
		bHasPhysicsAssetInstance=true
		TickGroup=TG_PreAsyncWork
		MinDistFactorForKinematicUpdate=0.2
		bChartDistanceFactor=true
		//bSkipAllUpdateWhenPhysicsAsleep=TRUE
		RBDominanceGroup=20
		bUseOnePassLightingOnTranslucency=TRUE
		bPerBoneMotionBlur=true
	End Object
	Mesh=WPawnSkeletalMeshComponent
	Components.Add(WPawnSkeletalMeshComponent)
 
	drawscale = 0.7
 
	Begin Object Name=CollisionCylinder
		CollisionRadius=+010.000000
		CollisionHeight=+44.000000
	End Object
	CylinderComponent=CollisionCylinder
	


	baseeyeheight = 27; // was21...want to net ~27, but accomodating for crouch
	CrouchHeight=45.0
	JumpZ=0.0
	//AccelRate=0.0 // set to eliminate movement

	

}
