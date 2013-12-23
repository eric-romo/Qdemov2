class QPlayerController extends UTPlayerController;

var LHandPawn LeftHand, RightHand;
var vector SpawnLocation;
var rotator spawnrotation;
var vector LeftPosition, RightPosition,  Leftposition_old, Rightposition_old, leftposition_delta, rightposition_delta;
var rotator LeftOrientation, RightOrientation;
var rotator leftorientation_new_world, rightorientation_new_world;
var sixense TheSixense;
var Matrix sxMat;
var vector leftx, lefty, leftz, L_objx, L_objy, L_objz, leftx_old, lefty_old, leftz_old, leftx_delta, lefty_delta, leftz_delta, L_offsetx, L_offsety, L_offsetz;
var vector left_old_transpose_x, left_old_transpose_y, left_old_transpose_z;
var vector rightx, righty, rightz, R_objx, R_objy, R_objz, rightx_old, righty_old, rightz_old, rightx_delta, righty_delta, rightz_delta, R_offsetx, R_offsety, R_offsetz;
var vector right_old_transpose_x, right_old_transpose_y, right_old_transpose_z;
var vector newpawnlocation;
var float pos_scale, base_height;
var vector base_dist;
var bool bwastouchingL, bwastouchingR, bfirstblockpressed, bjengapressed, bmirror_spawned, bvideo_spawned, bwhiteboard_spawned;
var array<firstblockactor> firstblock;
var array<jengaactor> jengablock;
var texturemovie movie_texture_var, movie_texture_var1, webcam1_texture, webcam2_texture, popupmovie; //used to control play and pause for movie texture
var mirroractor themirror;
var videoactor thevideo;
var presentationactor thepresentation;
var whiteboardactor thewhiteboard;
var int whiteboard_count, whiteboard_trigger;
var bool bplayerchecked;
var float initial_yaw, cos_initial_yaw, sin_initial_yaw;
var SkeletalMesh transformedmesh;
var enterpriseactor enterpriseobject;
var array<enterprisepopup> enterpriseinfo;
var array<consumeractor> consumerobjects;

`define m33el(x, y) `y + `x * 3


simulated event PostBeginPlay()
{	
	

	super.PostBeginPlay();
	
	
	TheSixense = new class'Sixense';
	TheSixense.sixenseInit();
	TheSixense.sixenseGetAllNewestData(TheSixense.TheControllerData);
	TheSixense.sixenseSetFilterEnabled(1);

	`log("I have arrived in the controller...should spawn now!");
	
	spawnlocation.X=-560;
	spawnlocation.Y=-224;
	spawnlocation.Z=377;

	LeftHand = spawn(class'LHandPawn',,,spawnlocation);
	
	spawnlocation.X=-360;
	spawnlocation.Y=200;
	spawnlocation.Z=800;

	RightHand = spawn(class'LHandPawn',,,spawnlocation); //cleaner way to do this?  spawnlocation is hard coded...

	movie_texture_var.Pause();
	movie_texture_var1.Pause();//sets movie as initially paused
	webcam1_texture.Pause();
	webcam2_texture.Pause();
	popupmovie.Pause();
	base_dist.X = 600;

	
	
}


event PlayerTick( float DeltaTime )
{

	if (pawn != none && !bplayerchecked)
	{   
		initial_yaw = pawn.Rotation.Yaw;
		cos_initial_yaw = cos(3.14159 / 2 / 16384 * initial_yaw);
		sin_initial_yaw = sin(3.14159 / 2 / 16384 * initial_yaw);
		bplayerchecked = true;
		if (playerreplicationinfo.PlayerID == 257)
		{
			call_changemesh();
		}
		`log("initial yaw: " $ initial_yaw);
	}
	
	

	Leftposition_old = leftposition;
	Rightposition_old = rightposition;
	

	TheSixense.sixenseGetAllNewestData(TheSixense.TheControllerData);
	
	if (thesixense.TheControllerData.controller[1].buttons == 8)
	{thesixense.Calibrate();
	base_dist.x = -thesixense.origin.X;
	base_dist.Y = thesixense.origin.Y;
	}

	if (thesixense.TheControllerData.controller[1].buttons == 16)
		thesixense.calibrated = false;


	if (thesixense.calibrated ==true)
		thesixense.ParseData();

	//begin sixense position and orientation
	//position - need to work on scaling...

	if (pawn != none)
	{
	leftposition.X = pawn.Location.X + pos_scale * cos_initial_yaw * (base_dist.X - TheSixense.TheControllerData.controller[0].pos[2]) + pos_scale * sin_initial_yaw * (TheSixense.TheControllerData.controller[0].pos[0] - base_dist.Y);
	LeftPosition.Y=pawn.Location.Y + pos_scale * cos_initial_yaw * (TheSixense.TheControllerData.controller[0].pos[0] - base_dist.Y) + pos_scale* sin_initial_yaw * (base_dist.X - TheSixense.TheControllerData.controller[0].pos[2]);
	LeftPosition.Z=base_height + pos_scale * TheSixense.TheControllerData.controller[0].pos[1];
	
	LeftHand.setlocation(LeftPosition);  
	
	rightposition.X = pawn.Location.X + pos_scale * cos_initial_yaw * (base_dist.X - TheSixense.TheControllerData.controller[1].pos[2]) + pos_scale * sin_initial_yaw * (TheSixense.TheControllerData.controller[1].pos[0] - base_dist.Y);
	rightPosition.Y=pawn.Location.Y + pos_scale * cos_initial_yaw * (TheSixense.TheControllerData.controller[1].pos[0] - base_dist.Y) + pos_scale* sin_initial_yaw * (base_dist.X - TheSixense.TheControllerData.controller[1].pos[2]);
	RightPosition.Z=base_height + pos_scale * TheSixense.TheControllerData.controller[1].pos[1];
	
	RightHand.setlocation(RightPosition);
	}

	//orientation
	//adding orientation transformation from Sixense to Unreal format
	
	
	//X Basis Vector
	sxMat.XPlane.X = TheSixense.TheControllerData.controller[0].rot_mat[ `m33el(2, 2) ]; 
	sxMat.XPlane.Y = -TheSixense.TheControllerData.controller[0].rot_mat[ `m33el(2, 0) ]; 
	sxMat.XPlane.Z = -TheSixense.TheControllerData.controller[0].rot_mat[ `m33el(2, 1) ];
	sxMat.XPlane.W = 0;
	
	//Y Basis Vector
	sxMat.YPlane.X = -TheSixense.TheControllerData.controller[0].rot_mat[ `m33el(0, 2) ];
	sxMat.YPlane.Y = TheSixense.TheControllerData.controller[0].rot_mat[ `m33el(0, 0) ];
	sxMat.YPlane.Z = TheSixense.TheControllerData.controller[0].rot_mat[ `m33el(0, 1) ]; 
	sxMat.YPlane.W = 0;
	
	//Z Basis Vector
	sxMat.ZPlane.X = -TheSixense.TheControllerData.controller[0].rot_mat[ `m33el(1, 2) ];
	sxMat.ZPlane.Y = TheSixense.TheControllerData.controller[0].rot_mat[ `m33el(1, 0) ];
	sxMat.ZPlane.Z = TheSixense.TheControllerData.controller[0].rot_mat[ `m33el(1, 1) ];
	sxMat.ZPlane.W = 0;
	
	//W Basis Vector
	sxMat.WPlane.X = 0;
	sxMat.WPlane.Y = 0;
	sxMat.WPlane.Z = 0;
	sxMat.WPlane.W = 1;

	leftorientation = matrixgetrotator(sxMat);
	
	leftorientation.Roll = cos_initial_yaw * leftorientation.roll;
	leftorientation.Pitch = cos_initial_yaw *leftorientation.Pitch;

	LeftHand.SetRotation(LeftOrientation);

//X Basis Vector
	sxMat.XPlane.X = TheSixense.TheControllerData.controller[1].rot_mat[ `m33el(2, 2) ]; 
	sxMat.XPlane.Y = -TheSixense.TheControllerData.controller[1].rot_mat[ `m33el(2, 0) ]; 
	sxMat.XPlane.Z = -TheSixense.TheControllerData.controller[1].rot_mat[ `m33el(2, 1) ];
	sxMat.XPlane.W = 0;
	
	//Y Basis Vector
	sxMat.YPlane.X = -TheSixense.TheControllerData.controller[1].rot_mat[ `m33el(0, 2) ];
	sxMat.YPlane.Y = TheSixense.TheControllerData.controller[1].rot_mat[ `m33el(0, 0) ];
	sxMat.YPlane.Z = TheSixense.TheControllerData.controller[1].rot_mat[ `m33el(0, 1) ]; 
	sxMat.YPlane.W = 0;
	
	//Z Basis Vector
	sxMat.ZPlane.X = -TheSixense.TheControllerData.controller[1].rot_mat[ `m33el(1, 2) ];
	sxMat.ZPlane.Y = TheSixense.TheControllerData.controller[1].rot_mat[ `m33el(1, 0) ];
	sxMat.ZPlane.Z = TheSixense.TheControllerData.controller[1].rot_mat[ `m33el(1, 1) ];
	sxMat.ZPlane.W = 0;
	
	//W Basis Vector
	sxMat.WPlane.X = 0;
	sxMat.WPlane.Y = 0;
	sxMat.WPlane.Z = 0;
	sxMat.WPlane.W = 1;

	rightorientation = matrixgetrotator(sxMat);

	rightorientation.Roll = cos_initial_yaw * rightorientation.roll + sin_initial_yaw * rightorientation.Pitch;
	rightorientation.Pitch = cos_initial_yaw *rightorientation.Pitch + sin_initial_yaw * rightorientation.roll;

	RightHand.SetRotation(RightOrientation);
//end sixense position and orientation	
	
//calculate delta position and orientation

	leftposition_delta = leftposition - leftposition_old;
	
	rightposition_delta = rightposition - rightposition_old;
		
	leftx_old = leftx;
	lefty_old = lefty;
	leftz_old= leftz;

	getaxes(leftorientation, leftx, lefty, leftz);
	
	leftx_delta = leftx - leftx_old;
	lefty_delta = lefty - lefty_old;
	leftz_delta = leftz - leftz_old;

	rightx_old = rightx;
	righty_old = righty;
	rightz_old= rightz;

	getaxes(rightorientation, rightx, righty, rightz);
	
	rightx_delta = rightx - rightx_old;
	righty_delta = righty - righty_old;
	rightz_delta = rightz - rightz_old;

	//touch detection

	//left hand
	if (lefthand.Touching.length != 0)
	{`log("TOUCH!:" $ lefthand.Touching[0]);
	lefthand.changecolor(true);}
	
	if (lefthand.Touching.Length != 0)
	{
	if (thesixense.TheControllerData.controller[0].trigger>0 && lefthand.Touching[0].Class != class'whiteboardactor')
		{
			if (bwastouchingL)
				lefthand.Touching[0].SetRotation(leftorientation_new_world);
			
			getaxes(lefthand.Touching[0].Rotation, L_objx, L_objy, L_objz);
		
		

		//computing delta for object basis vectors
		L_offsetx = resultx(left_old_transpose_x, left_old_transpose_y, left_old_transpose_z,L_objx);
		L_offsety = resulty(left_old_transpose_x, left_old_transpose_y, left_old_transpose_z,L_objy);
		L_offsetz = resultz(left_old_transpose_x, left_old_transpose_y, left_old_transpose_z,L_objz);

		L_offsetx = resultx(leftx_delta, lefty_delta, leftz_delta, L_offsetx);
		L_offsety = resulty(leftx_delta, lefty_delta, leftz_delta, L_offsety);
		L_offsetz = resultz(leftx_delta, lefty_delta, leftz_delta, L_offsetz);

		L_objx = L_objx+L_offsetx;
		L_objy = L_objy+L_offsety;
		L_objz = L_objz+L_offsetz;

		leftorientation_new_world = orthorotation(L_objx, L_objy, L_objz);

		moveobject(lefthand.Touching[0], leftposition_delta, leftorientation_new_world);

		bwastouchingL = true;
		}
	

	if (thesixense.TheControllerData.controller[0].trigger==0 && bwastouchingL 
		&& lefthand.Touching[0].Class != class'whiteboardactor') 
		{
		bwastouchingL=false;
		
		if (lefthand.Touching[0].Class != class'enterprisepopup')
		{
			lefthand.Touching[0].SetPhysics(PHYS_rigidbody);
			if (role<role_authority)
				serversetphysics(lefthand.Touching[0]);
		}
		}
	}

	if (lefthand.touching.Length == 0)
	{//`log("NO TOUCH");
	lefthand.changecolor(false);}

	//right hand
	if (righthand.Touching.Length != 0 )
	{`log("TOUCH!:" $ righthand.Touching[0]);
	righthand.changecolor(true);
		if (thesixense.TheControllerData.controller[1].trigger>0 && righthand.Touching[0].Class != class'whiteboardactor' )
		{
		
		if (bwastouchingR)
			righthand.Touching[0].SetRotation(rightorientation_new_world);
		
		getaxes(righthand.Touching[0].Rotation, R_objx, R_objy, R_objz);
	
		//computing delta for object basis vectors
		R_offsetx = resultx(right_old_transpose_x, right_old_transpose_y, right_old_transpose_z,R_objx);
		R_offsety = resulty(right_old_transpose_x, right_old_transpose_y, right_old_transpose_z,R_objy);
		R_offsetz = resultz(right_old_transpose_x, right_old_transpose_y, right_old_transpose_z,R_objz);

		R_offsetx = resultx(rightx_delta, righty_delta, rightz_delta, R_offsetx);
		R_offsety = resulty(rightx_delta, righty_delta, rightz_delta, R_offsety);
		R_offsetz = resultz(rightx_delta, righty_delta, rightz_delta, R_offsetz);
	
		R_objx = R_objx+R_offsetx;
		R_objy = R_objy+R_offsety;
		R_objz = R_objz+R_offsetz;

		rightorientation_new_world = orthorotation(R_objx, R_objy, R_objz);

		moveobject(righthand.Touching[0], rightposition_delta, rightorientation_new_world);

		bwastouchingR = true;
		}
		if (thesixense.TheControllerData.controller[1].trigger==0 && bwastouchingR 
			&& righthand.Touching[0].Class != class'whiteboardactor') 
		{
			
			bwastouchingR=false;
			if (righthand.Touching[0].Class != class'enterprisepopup')
			{   
				righthand.Touching[0].SetPhysics(PHYS_rigidbody);
				if (role<role_authority)
					serversetphysics(righthand.Touching[0]);
			}
		}
	}

	if (righthand.Touching.Length ==0)
	{righthand.changecolor(false);}


	getunaxes(leftorientation, left_old_transpose_x, left_old_transpose_y, left_old_transpose_z);
	getunaxes(rightorientation, right_old_transpose_x, right_old_transpose_y, right_old_transpose_z);

	
	processarmandhead(); //move limbs in pawn


//end touch and movement

//whiteboard code
	if (lefthand.Touching.Length != 0)
	{
	if (lefthand.Touching[0].Class == class'whiteboardactor' && thesixense.TheControllerData.controller[0].trigger>0)
	{
		if (whiteboard_count == 1)
		{worldinfo.MyDecalManager.SpawnDecal(DecalMaterial'demo_asset.whiteboard_marker_decal', lefthand.Location,lefthand.Rotation,5,5,30,false,,,,,,,,500);
		 whiteboard_count = 2;
		}
		else
		{whiteboard_count = whiteboard_count + 1;
		if (whiteboard_count == whiteboard_trigger)
			whiteboard_count = 1;
		}
	}
	}

	if (righthand.Touching.Length != 0)
	{
	if (righthand.Touching[0].Class == class'whiteboardactor' && thesixense.TheControllerData.controller[1].trigger>0)
	{
		if (whiteboard_count == 1)
		{	worldinfo.MyDecalManager.SpawnDecal(DecalMaterial'demo_asset.whiteboard_marker_decal', righthand.Location,righthand.Rotation,5,5,30,false,,,,,,,,500);
		whiteboard_count = 2;}
		else
		{whiteboard_count = whiteboard_count + 1;
		if (whiteboard_count == whiteboard_trigger)
			whiteboard_count = 1;
		}
	}
	}
//end whiteboard code

// fiddle with spawning new objects

	if (thesixense.TheControllerData.controller[0].buttons == 32 && bfirstblockpressed == false)
		addfirstblocks();

	if (thesixense.TheControllerData.controller[0].buttons == 64)
		removefirstblocks();

 /*   if (thesixense.TheControllerData.controller[0].buttons == 8 && bjengapressed == false)
		addjenga();

	if (thesixense.TheControllerData.controller[0].buttons == 16)
		removejengablocks();*/
//end object creation and destruction

	

	if ( !bShortConnectTimeOut )
	{
		bShortConnectTimeOut = true;
		ServerShortTimeout();
	}

	if ( Pawn != AcknowledgedPawn )
	{
		if ( Role < ROLE_Authority )
		{
			// make sure old pawn controller is right
			if ( (AcknowledgedPawn != None) && (AcknowledgedPawn.Controller == self) )
				AcknowledgedPawn.Controller = None;
		}
		AcknowledgePossession(Pawn);
	}

	PlayerInput.PlayerInput(DeltaTime);
	if ( bUpdatePosition )
	{
		ClientUpdatePosition();
	}
	PlayerMove(DeltaTime);

	AdjustFOV(DeltaTime);
}

event UpdateRotation( float DeltaTime )
{
	local Rotator	DeltaRot, newRotation, ViewRotation;
	local Oculus    OC;

	ViewRotation = Rotation;
	if (Pawn!=none)
	{
		Pawn.SetDesiredRotation(ViewRotation);
	}

	// Calculate Delta to be applied on ViewRotation
	DeltaRot.Yaw	= PlayerInput.aTurn;
	DeltaRot.Pitch	= PlayerInput.aLookUp;

	// Oculus
	OC = class'Oculus'.static.GetGlobals();
	if (class'Oculus'.static.IsEnabled() && OC != None && OC.IsPlayer(self))
	{
		if (OC.bDisableControllerPitch)
			DeltaRot.Pitch	= 0;

		MouseAim.Yaw += PlayerInput.aMouseAimX;
		MouseAim.Pitch += PlayerInput.aMouseAimY;
		MouseAim = Normalize(MouseAim);
		if (MouseAim.Yaw >= OC.MouseAimLimit)
		{
			DeltaRot.Yaw += (MouseAim.Yaw - OC.MouseAimLimit);
			MouseAim.Yaw = OC.MouseAimLimit;
		}
		else if (MouseAim.Yaw <= -OC.MouseAimLimit)
		{
			DeltaRot.Yaw += (MouseAim.Yaw + OC.MouseAimLimit);
			MouseAim.Yaw = -OC.MouseAimLimit;
		}
		if (MouseAim.Pitch >= OC.MouseAimPitchLimit)
			MouseAim.Pitch = OC.MouseAimPitchLimit;
		else if (MouseAim.Pitch <= -OC.MouseAimPitchLimit)
			MouseAim.Pitch = -OC.MouseAimPitchLimit;
	}

	ProcessViewRotation( DeltaTime, ViewRotation, DeltaRot );

	// If Camera is animating, do not apply the HMD rotation yet, because it will not be
	// used by the Camera, leading to bad headlook behavior.
/*	if (OC != None && OC.IsPlayer(self) && (PlayerCamera == None || !PlayerCamera.IsAnimActive()))
	{
		OC.ApplyHmdRotation(self, ViewRotation);
	}
*/	
	SetRotation(ViewRotation);

	ViewShake( deltaTime );

	if (Pawn != None)
	{
		NewRotation = ViewRotation;
		Pawn.FaceRotation(NewRotation, deltatime);
	}
}

simulated event Destroyed()
{
	
	
	TheSixense.sixenseExit();
	TheSixense = none;

	if (LocalPlayer(Player) != None)
	{
		LocalPlayer(Player).ViewportClient.bDisableWorldRendering = false;
	}

	Super.Destroyed();
}

simulated function processarmandhead()
{

	local qpawn QP;

	
	if (pawn != none)
	{
	QP = Qpawn(pawn);
		
		QP.righthandrotation = QuatToRotator(TheSixense.altControllerData.Controller[1].Quat_rot);
		QP.lefthandrotation = QuatToRotator(TheSixense.altControllerData.Controller[0].Quat_rot);
		
		QP.RightArmLocation = TheSixense.altControllerData.Controller[1].vector_Pos;
		QP.LeftArmLocation = TheSixense.altControllerData.Controller[0].vector_Pos;

		QP.righthandrotation.Roll = qp.righthandrotation.roll - initial_yaw;
		qp.righthandrotation.Pitch = cos_initial_yaw * qp.righthandrotation.Pitch + initial_yaw;
			
		qp.lefthandrotation.Roll = qp.lefthandrotation.Roll - initial_yaw;
		qp.lefthandrotation.pitch = cos_initial_yaw* qp.lefthandrotation.pitch - initial_yaw;


		qp.RightArmLocation.X = cos_initial_yaw * qp.RightArmLocation.X;
		qp.RightArmLocation.Y = cos_initial_yaw * qp.RightArmLocation.Y;
		qp.LeftArmLocation.X = cos_initial_yaw * qp.LeftArmLocation.X;
		qp.LeftArmLocation.Y = cos_initial_yaw * qp.LeftArmLocation.Y;
		
		qp.pawn_initial_yaw = initial_yaw;

		//GetPlayerViewPoint(QP.headposition,QP.headrotation);
		QP.headrotation = QuatToRotator(CurHmdOrientation);


		QP.ToggleBool();
	}

}


simulated function moveobject(actor object_moved, vector position_delta, rotator rotation_delta)
{
	local float changeinX, changeinY, changeinZ, rot_delta_roll, rot_delta_pitch, rot_delta_yaw;

	changeinX = position_delta.X;
	changeinY = position_delta.Y;
	changeinZ = position_delta.Z;
	rot_delta_roll = rotation_delta.Roll;
	rot_delta_pitch = rotation_delta.pitch;
	rot_delta_yaw = rotation_delta.yaw;
	
	object_moved.SetPhysics(PHYS_none);
	object_moved.SetLocation(object_moved.Location + position_delta);
	object_moved.SetRotation(rotation_delta);
	
	`log("client pos.z: " $ object_moved.Location.Z);

	if (role<role_authority)
	{  
	servermoveobject(object_moved, changeinX, changeinY, changeinZ,rot_delta_roll, rot_delta_pitch, rot_delta_yaw);
	}
	
}

reliable server function servermoveobject(actor s_object_moved, float s_changeinX, 
	float s_changeinY, float s_changeinZ, float s_rot_delta_roll, float s_rot_delta_pitch, float s_rot_delta_yaw)
{
	
		local vector s_position_delta;
		local rotator s_rotation_delta;
		
		s_position_delta.X = s_changeinX;
		s_position_delta.Y = s_changeinY;
		s_position_delta.Z = s_changeinZ;

		s_object_moved.SetPhysics(PHYS_none);
		s_object_moved.SetLocation(s_object_moved.Location + s_position_delta);
		
		s_rotation_delta.Roll = s_rot_delta_roll;
		s_rotation_delta.pitch = s_rot_delta_pitch;
		s_rotation_delta.yaw = s_rot_delta_yaw;

		s_object_moved.SetRotation(s_rotation_delta);
	

		`log("server pos.z: " $ s_object_moved.Location.Z);
		
}

reliable server function serversetphysics(actor other)
{
	other.SetPhysics(PHYS_rigidbody);
}

exec function addfirstblocks()
{
	local int i, j, k, blockindex;
	
	blockindex = 0;
	
	if (Role < Role_Authority)
	{   serveraddfirstblocks(); }
	else
	{
	for (k=0; k<=3; k++)
		for (i=0; i<=2; i++)
			for (j=0; j<=2; j++)
			{
				spawnlocation.X = -855 + 75*(i+1);
				spawnlocation.Y = -180  + 75 + (j+1)*50;
				spawnlocation.Z = 85 + 50*k;
				if (randrange(0,1)>0.40)
					{firstblock[blockindex] = spawn(class'firstblockactor',,,spawnlocation);
					blockindex++;
					}
			}

	}
	bfirstblockpressed = true;
}

reliable server function serveraddfirstblocks()
{
	local int i, j, k, blockindex;
	
	blockindex = 0;
	
	for (k=0; k<=3; k++)
		for (i=0; i<=2; i++)
			for (j=0; j<=2; j++)
			{
				spawnlocation.X = -855 + 75*(i+1);
				spawnlocation.Y = -180  + 75 + (j+1)*50;
				spawnlocation.Z = 85 + 50*k;
				if (randrange(0,1)>0.60)
					{firstblock[blockindex] = spawn(class'firstblockactor',,,spawnlocation);
					blockindex++;
					}
			}
}

exec function removefirstblocks()
{
    local int destroyindex;

	if (role < role_authority)
	{serverremovefirstblocks();}
	else
	{
	for (destroyindex = 0; destroyindex <=firstblock.Length; destroyindex++) 
			{firstblock[destroyindex].Destroy();}
	}
		
	bfirstblockpressed = false;
	
}

reliable server function serverremovefirstblocks()
{
	 local int destroyindex;
	
	 for (destroyindex = 0; destroyindex <=firstblock.Length; destroyindex++) 
			{firstblock[destroyindex].Destroy();}

}

function addjenga()
{
	local int j, k, blockindex;
	local rotator jengarotation;

	if (bfirstblockpressed == true)
		removefirstblocks();

	blockindex = 0;
	jengarotation.Pitch = 0;
	jengarotation.Roll = 0;
	jengarotation.Yaw = -16000;

	for (k=0; k<=7; k++)
			for (j=0; j<=2; j++)
			{   if(k % 2 ==0)
					{spawnlocation.X = pawn.Location.X + 50;
					spawnlocation.Y = pawn.Location.Y -5 + j*5;
					spawnlocation.Z = pawn.Location.Z + 10*k;
					jengablock[blockindex] = spawn(class'jengaactor',,,spawnlocation,jengarotation);
					blockindex++;
					}
				else
				{   spawnlocation.X = pawn.Location.X + 50 -5 + j*5;
					spawnlocation.Y = pawn.Location.Y; 
					spawnlocation.Z = pawn.Location.Z + 10*k;
					jengablock[blockindex] = spawn(class'jengaactor',,,spawnlocation);
					blockindex++;
					
				}
					
			}
	bjengapressed = true;

}

function removejengablocks()
{
    local int destroyindex;
	
	for (destroyindex = 0; destroyindex <=jengablock.Length; destroyindex++) 
			{jengablock[destroyindex].Destroy();}
			bjengapressed = false;
}


exec function reset_sixense_cal()
{   thesixense.calibrated=false;}

exec function call_sixense_cal()
{   thesixense.Calibrate();
	base_dist.x = -thesixense.origin.X;
	base_dist.Y = thesixense.origin.Y;}

exec function spawn_mirror()
{
	qpawn(pawn).mirror_create();

}

exec function spawn_video()
{
	qpawn(pawn).movie_create();
}

exec function call_toggle_movie()
{
	`log("toggling movie1");
	qpawn(pawn).toggle_movie();
}

exec function call_switchmovie()
{
	qpawn(pawn).switchmovie();
}

exec function call_toggle_movie2()
{
	`log("toggling movie2");
	qpawn(pawn).toggle_movie2();
}

exec function call_webcams()
{
	qpawn(pawn).server_add_webcams();
}

exec function spawn_presentation()

{
	spawnlocation.X = pawn.Location.X + 275;
	spawnlocation.Y = pawn.Location.Y -50;
	spawnlocation.Z = pawn.Location.Z;

	spawnrotation.yaw = 13000;
	//spawnrotation.pitch = 16000;
	
	if (thepresentation != none)
	{	thepresentation.Destroy();
		thepresentation = none;

	}
	else
	{   thepresentation = spawn(class'presentationactor',,,spawnlocation,spawnrotation);
		thepresentation.slidenumber =1;
		thepresentation.changeslide();

	}


}

exec function slideadvance()
{

		thepresentation.slidenumber += 1;
		thepresentation.changeslide();

}

exec function slideback()
{

	thepresentation.slidenumber -= 1;
	thepresentation.changeslide();
}

exec function spawn_whiteboard()
{
	spawnlocation.X = pawn.Location.X + 25;
	spawnlocation.Y = pawn.Location.Y - 125;
	spawnlocation.Z = pawn.Location.Z + 25;

	spawnrotation.yaw = 0;
	
	if (bwhiteboard_spawned)
	{	thewhiteboard.Destroy();
		bwhiteboard_spawned = false;}
	else
	{   thewhiteboard = spawn(class'whiteboardactor',,,spawnlocation,spawnrotation);
		bwhiteboard_spawned = true;}


}

exec function call_changemesh()
{
	`log('in call_changemesh');
	if (role<role_authority)
		server_changemesh();    
	changemesh();
}

reliable server function server_changemesh()
{
	`log('in server_changemesh');
	self.Pawn.Mesh.SetSkeletalMesh(transformedMesh);
	self.Pawn.Mesh.SetMaterial(0, Material'testpackage1.Materials.Frames');
	self.Pawn.Mesh.SetMaterial(1, Material'testpackage1.Materials.Lens');
	self.Pawn.Mesh.SetMaterial(2, Material'testpackage1.Materials.Toon_COL');
//	self.Pawn.mesh.SetScale(3.0);
}

simulated function changemesh()
{
	`log('in client_changemesh');
	self.Pawn.Mesh.SetSkeletalMesh(transformedMesh);
	self.Pawn.Mesh.SetMaterial(0, Material'testpackage1.Materials.Frames');
	self.Pawn.Mesh.SetMaterial(1, Material'testpackage1.Materials.Lens');
	self.Pawn.Mesh.SetMaterial(2, Material'testpackage1.Materials.Toon_COL');
//	self.Pawn.mesh.SetScale(3.0);
}

simulated exec function teleportto()
{
	//this doesn't work with some positions...but does maintain orientation
	//doesn't yet work on client, but works on server
	`log("trying to teleport!");
	pawn.SetLocation(pawn.location + vect(250,250,0));
}

exec function add_enterprise()
{
	local int i;
	
	if (role<role_authority)
		server_add_enterprise();
	else
	{
	
	spawnlocation.X = -625;
	spawnlocation.Y = -275;
	spawnlocation.Z = 75;

	if(enterpriseobject == none)
		{
			enterpriseobject = spawn(class'enterpriseactor',,,spawnlocation);
			spawnlocation.X = -725;
			spawnlocation.Y = -150;
			spawnlocation.Z = 110;
			spawnrotation.Yaw = 32000;
			for (i=0; i<=3; i++)
			{
				enterpriseinfo[i] = spawn(class'enterprisepopup',,,spawnlocation, spawnrotation);
				spawnlocation.X += 75;
				if (i==1)
				{spawnlocation.X -= 150;
				spawnlocation.Z -=50;}
				enterpriseinfo[i].popupnumber = i;
				enterpriseinfo[i].changepopup();
			}
			

		}
	else
		{
			enterpriseobject.Destroy();
			enterpriseobject = none;
			for (i=0;i<=3; i++)
				enterpriseinfo[i].Destroy();
			popupmovie.Pause();
		}


	}
}

reliable server function server_add_enterprise()
{

	local int i;

	spawnlocation.X = -625;
	spawnlocation.Y = -275;
	spawnlocation.Z = 75;

	if(enterpriseobject == none)
		{
			enterpriseobject = spawn(class'enterpriseactor',,,spawnlocation);
			spawnlocation.X = -725;
			spawnlocation.Y = -150;
			spawnlocation.Z = 110;
			spawnrotation.Yaw = 32000;
			for (i=0; i<=3; i++)
			{
				enterpriseinfo[i] = spawn(class'enterprisepopup',,,spawnlocation, spawnrotation);
				spawnlocation.X += 75;
				if (i==1)
				{spawnlocation.X -= 150;
				spawnlocation.Z -=50;}
				enterpriseinfo[i].popupnumber = i;
				enterpriseinfo[i].changepopup();
			}
			

		}
		else
			{
				enterpriseobject.Destroy();
				enterpriseobject = none;
				for (i=0;i<=3; i++)
					enterpriseinfo[i].Destroy();
				popupmovie.Pause();
			}

}

exec function add_consumer()
{
	local int i;
	
	if (role<role_authority)
		server_add_consumer();
	else
	{
	spawnlocation.X = -650;
	spawnlocation.Y = -300;
	spawnlocation.Z = 75;

	if (consumerobjects[0] == none)
	{ for (i=0; i<=2; i++)
		{
			consumerobjects[i] = spawn(class'consumeractor',,,spawnlocation);
			spawnlocation.Y += 50;
			consumerobjects[i].consumernumber = i;
			consumerobjects[i].changeconsumermesh();
		}
	}
	else 
	{for (i=0; i<=2; i++)
		{
			consumerobjects[i].Destroy();
			consumerobjects[i] = none;
		}
	
	}
	}
}

reliable server function server_add_consumer()
{

	local int i;

	spawnlocation.X = -650;
	spawnlocation.Y = -300;
	spawnlocation.Z = 75;

	if (consumerobjects[0] == none)
	{ for (i=0; i<=2; i++)
		{
			consumerobjects[i] = spawn(class'consumeractor',,,spawnlocation);
			spawnlocation.Y += 50;
			consumerobjects[i].consumernumber = i;
			consumerobjects[i].changeconsumermesh();
		}
	}
	else 
	{for (i=0; i<=2; i++)
		{
			consumerobjects[i].Destroy();
			consumerobjects[i] = none;
		}
	
	}

}



event AdjustHUDRenderSize(out int X, out int Y, out int SizeX, out int SizeY, const int FullScreenSizeX, const int FullScreenSizeY)
{
}

function vector resultx (vector Ax, vector Ay, vector Az, vector Bx)
{
	local vector result_temp;
	
	result_temp.x = Ax.X * Bx.X + Ay.x * Bx.Y + Az.X * Bx.Z;
	result_temp.y = Ax.Y * Bx.X + Ay.Y * Bx.Y + Az.Y * Bx.z;
	result_temp.z = Ax.z * Bx.X + Ay.z * Bx.Y + Az.z * Bx.z;

	return result_temp;
}

function vector resulty (vector Ax, vector Ay, vector Az, vector By)
{
	local vector result_temp;
	
	result_temp.x = Ax.X * By.X + Ay.x * By.Y + Az.X * By.Z;
	result_temp.y = Ax.Y * By.X + Ay.Y * By.Y + Az.Y * By.z;
	result_temp.z = Ax.z * By.X + Ay.z * By.Y + Az.z * By.z;

	return result_temp;
}

function vector resultz (vector Ax, vector Ay, vector Az, vector Bz)
{
	local vector result_temp;
	
	result_temp.x = Ax.X * Bz.X + Ay.x * Bz.Y + Az.X * Bz.Z;
	result_temp.y = Ax.Y * Bz.X + Ay.Y * Bz.Y + Az.Y * Bz.z;
	result_temp.z = Ax.z * Bz.X + Ay.z * Bz.Y + Az.z * Bz.z;

	return result_temp;
}

DefaultProperties
{
	pos_scale = 0.25;
	base_height = 60;
	bwastouchingL = false;
	bwastouchingR = false;
	bfirstblockpressed = false;
	bmirror_spawned = false;
	bvideo_spawned = false;
	bwhiteboard_spawned = false;
	bplayerchecked = false;
//	bduck=1; //crouched?

	
	transformedMesh= SkeletalMesh'testpackage1.avatars.Vincent_avatar';
	movie_texture_var = TextureMovie'demo_asset.BigGame2013Highlights';
	movie_texture_var1 = TextureMovie'demo_asset.AvatarMovieTrailer';
	webcam1_texture = TextureMovie'demo_asset.webcam1';
	webcam2_texture = TextureMovie'demo_asset.webcam2';
	popupmovie = TextureMovie'testpackage1.ent_popup_video';


	

	whiteboard_count = 1;
	whiteboard_trigger = 5;

//	bmovie1playing = false;


}
