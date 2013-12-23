class QHud extends UDKHUD;


function drawhud()
{
	//local qplayercontroller PC;
	

	local consumeractor consumertouched;
	local vector worldhudlocation, screenhudlocation, CameraViewDirection, CameraLocation, objectdirection;
	local rotator CameraRotation;
	local float objectxoffset, objectyoffset, anglebetween;

	super.DrawHUD();
	
	/*
	PC = qplayercontroller(getalocalplayercontroller());

	canvas.SetPos(320,400,50);
	
	if (PC.TheSixense.calibrated)
	{canvas.DrawText("Hello world.");
	}
	*/

	canvas.Font = Font'EngineFonts.calibri_font';


	PlayerOwner.GetPlayerViewPoint(CameraLocation, CameraRotation);
	CameraViewDirection = Vector(CameraRotation);

foreach dynamicactors(class'consumeractor', consumertouched)
	{
	if (consumertouched.bwastouched)
	{
		objectDirection = Normal(consumertouched.Location - PlayerOwner.Pawn.Location);
		anglebetween = acos(normal(objectdirection) dot normal(cameraviewdirection));

		if (anglebetween < 0.65)
		{
			WorldHUDLocation = consumertouched.Location;
			ScreenHUDLocation = Canvas.Project(WorldHUDLocation);
		
			objectXoffset = 30;
			objectYoffset = 150;

			canvas.SetPos(screenhudlocation.X - objectXoffset, screenhudlocation.Y - objectYoffset, 100);
			canvas.SetDrawColor(0,100,0);
			canvas.DrawText(consumertouched.line1[consumertouched.consumernumber],true);
			canvas.DrawText(consumertouched.line2[consumertouched.consumernumber],true);
			canvas.DrawText(consumertouched.line3[consumertouched.consumernumber],true);
		}
	}
	}

}

DefaultProperties
{


}
