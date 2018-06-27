import 'dart:async';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
//import 'package:geolocation/geolocation.dart';

class Item 
{
	String key;
  String title;
	String productNumber;
	String location;
	String position; 
	String quantity;
	String tearWeight; // tear weight
	String totalWeight; // total weight
	String lastEdit; // tracks whoever last edited an item
	bool empty;
  Future<File> image;
  //LocationResult gps;
  Item(this.title, this.productNumber, this.location, this.position, this.quantity, this.tearWeight, this.totalWeight, this.lastEdit, this.empty, this.image);// this.gps);

  Item.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        title = snapshot.value["title"],
        productNumber = snapshot.value["productNumber"],
        location = snapshot.value["location"],
        position = snapshot.value["position"],
        quantity = snapshot.value["quantity"],
        tearWeight = snapshot.value["tearWeight"],
        totalWeight = snapshot.value["totalWeight"],
        lastEdit = snapshot.value["lastEdit"],
        empty = snapshot.value["empty"],
        image = snapshot.value["image"];
        //gps = snapshot.value["gps"];

  toJson() 
  {
    return 
    {
      "title": title,
      "productNumber": productNumber,
      "location": location,
      "position": position,
      "quantity" : quantity,
      "tearWeight" : tearWeight,
      "totalWeight" : totalWeight,
      "lastEdit" : lastEdit,
      "empty" : empty,
      "image" : image,
      //"gps" : gps

    };
  }
	// Item(String name, String numb, String loc, String spot, String quan, String tear, String tot, String edit, bool emptIn, Future<File> newImage)// LocationResult newGps)
	// {
	// 	title = name;
	// 	productNumber = numb;
	// 	location = loc;
	// 	position = spot;
	// 	quantity = quan;
	// 	tearWeight = tear;
	// 	totalWeight= tot;
	// 	lastEdit = edit;
	// 	empty = emptIn;
	// 	image = newImage;
	// 	//gps = newGps;
	// }

	bool isEmpty()
	{
		return empty;
	}
  
	// LocationResult getGps()
	// {
	// 	return this.gps;
	// }

	// void setGps(newGps)
	// {
	// 	this.gps = newGps;
	// }

	// double getLong()
	// {
	// 	if(this.gps.location == null)
	// 	{
	// 		return null;
	// 	}

	// 	return this.gps.location.longitude;
	// }

	// double getLat()
	// {
	// 	if(this.gps.location == null)
	// 	{
	// 		return null;
	// 	}
		
	// 	return this.gps.location.latitude;
	// }

	String getInfo(int id)
	{
		switch (id)
		{
			case 0:
				return this.title;
			case 1:
				return this.productNumber;
			case 2:
				return this.location;
			case 3:
				return this.position;
			case 4:
				return this.quantity;
			case 5:
				return this.tearWeight;
			case 6:
				return this.totalWeight;
			case 7:
				return this.lastEdit;
		}

		return 'Invalid id';
	}

	void editInfo(int id, String data)
	{
		switch (id)
		{
			case 0:
				this.title = data;
				break;
			case 1:
				this.productNumber = data;
				break;
			case 2:
				this.location = data;
				break;
			case 3:
				this.position = data;
				break;
			case 4:
				this.quantity = data;
				break;
			case 5:
				this.tearWeight = data;
				break;
			case 6:
				this.totalWeight = data;
				break;
			case 7:
				this.lastEdit = data;
				break;
		}
	}

	void setImage(Future<File> newImage)
	{
		this.image = newImage;
	}

	Future<File> getImage()
	{
		return this.image;
	}
  
	void setEmpty(bool emptyIn)
	{
		empty = emptyIn;
	}

}