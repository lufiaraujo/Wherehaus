import 'dataObj.dart';
import 'dart:async';
import 'dart:io';
//import 'dart:typed_data';
import 'dart:math';
//import 'package:flutter/services.dart' show rootBundle;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

final FirebaseDatabase database = FirebaseDatabase.instance;

class DataBase
{
	List<Item> itemArray; 
	List<int> inSearch;
	List<Item> notInSearch;
	DatabaseReference itemRef;

	DataBase()
	{
		final FirebaseDatabase database = FirebaseDatabase.instance;
		itemRef = database.reference().child('items');

		itemArray = [];

		inSearch = [];
		notInSearch = [];

		itemRef.onChildAdded.listen(_onEntryAdded);
		itemRef.onChildChanged.listen(_onEntryChanged);
		itemRef.onChildRemoved.listen(_onEntryRemoved);
	}

	void newItem({String title: '', String productNumber: '', String location: '', String position: '',
	String quantity: '',  String tearWeight: '',  String totalWeight: '',  String lastEdit: '', bool empty: true, imageUrl, newLat, newLong,newPO, newProcess, newCustomer, newSalesNumber, newPartNumber, newCreator})
	{
		Item item = new Item(title, productNumber, location, position, quantity, tearWeight, totalWeight, lastEdit, empty, imageUrl, newLat, newLong, newPO, newProcess, newCustomer, newSalesNumber, newPartNumber, newCreator);
		itemRef.push().set(item.toJson());
    //print('!Image string!'); 
    //print(image);
	}

	void edit(itemId, editNum, newValue)
	{
		var itemValue = "";
		switch (editNum)
		{
    case 0:
      itemValue = "title";
      break;
    case 1:
      itemValue = "productNumber";
      break;
    case 2:
      itemValue = "location";
      break;
    case 3:
      itemValue = "position";
      break;
    case 4:
      itemValue = "quantity";
      break;
    case 5:
      itemValue = "tearWeight";
      break;
    case 6:
      itemValue = "totalWeight";
      break;
    case 7:
      itemValue = "lastEdit";
      break;
    case 8:
      itemValue = "lat";
      break;
    case 9:
      itemValue = "long";
      break;
    case 10: 
      itemValue = "pONumber"; 
      break;
    case 11:
      itemValue = "processing"; 
      break;
    case 12:
      itemValue = "customer"; 
      break;
    case 13:
      itemValue = "salesNumber";
      break;
    case 14:
      itemValue = "partNumber";
      break;
    case 15:
      itemValue = "createad";
      break;
  }
  var itemKey = itemArray[itemId].key;
  itemRef.child(itemKey).child(itemValue).set(newValue);
	}

  // uploadImage(Future<File> futureImage, id) async
  // {
  //   //print(await futureImage);
  //   File image = await futureImage;
  //   var random = new Random().nextInt(10000);
  //   print("made it to the method?++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
  //   var ref = FirebaseStorage.instance.ref().child('image_$random.jpg');
  //   print("Made it past the reference YEEEEEEEEEEEEEEEEEEEEEEEEEHAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAW!+++++++++++++++++++++++++++++++++++++++++");
  //   final StorageUploadTask uploadTask = ref.putFile(image);
  //   print("Upload task this bois ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
  //   //final Uri downloadUrl = 
  //   (uploadTask.future).then( (futureTask) { itemArray[id].setImage(futureTask.downloadUrl.toString()); } );
  //   print("YEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEET++++++++++++++++++++++++++++++");
  //   //itemArray[id].setImage(downloadUrl.toString());

  //   print("Nibba we made it!-----------------------------------------------------------------------------------------------------------------------------------------------------");
  //   //print(downloadUrl.toString());
  //  // return(downloadUrl.toString());
  // }
  Future<Null> uploadImage(Future<File> image, id) async
  {
    File putImage = await image;
    final String fileName = "${Random().nextInt(10000)}.jpg";
    var ref = FirebaseStorage.instance.ref().child(fileName);
    final StorageUploadTask task = ref.putFile(putImage);
    final Uri downloadUrl = (await task.future).downloadUrl;
    print("YEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEET++++++++++++++++++++++++++++++");

    String urlString = downloadUrl.toString();
    itemArray[id].setImage(urlString);
    var itemKey = itemArray[id].key;
    itemRef.child(itemKey).child("imageUrl").set(urlString);
  }

	_onEntryAdded(Event event) 
	{
		itemArray.add(Item.fromSnapshot(event.snapshot));
	}

	_onEntryChanged(Event event) 
	{
		//detect which item is effected, replace
		var old = this.itemArray.singleWhere((entry) 
		{
			return entry.key == event.snapshot.key;
		});
		itemArray[itemArray.indexOf(old)] = Item.fromSnapshot(event.snapshot);
	}

	_onEntryRemoved(Event event) 
	{
		//detect which item is effected, remove from list
		var old = this.itemArray.singleWhere((entry) 
		{
			return entry.key == event.snapshot.key;
		});
		itemArray.removeAt(itemArray.indexOf(old));
	}

	List getDatabase()
	{
		return this.itemArray;
	}

	List getSearch()
	{
		return this.inSearch;
	}

	void delete(int id)
	{
		itemRef.child(itemArray[id].key).remove();
	}

	void search(String input, int id)
	{
		//exact match
		notInSearch.forEach((value)
		{
			if (value.getInfo(id).toLowerCase() == input.toLowerCase())
			{
				inSearch.add(itemArray.indexOf(value));
			}
		});

		notInSearch.removeWhere((value) => value.getInfo(id).toLowerCase() == input.toLowerCase());

		//similar titles
		notInSearch.forEach((value)
		{
			if (value.getInfo(id).toLowerCase().contains(input.toLowerCase()))
			{
				inSearch.add(itemArray.indexOf(value));
			}
		});

		notInSearch.removeWhere((value) => value.getInfo(id).toLowerCase().contains(input.toLowerCase()));
	}

	void update(String input)
	{
		inSearch = [];
		notInSearch = [];

		notInSearch.addAll(itemArray.reversed);

		for (int i = 0; i < 13; i++) // was 7 ask jack
		{
			search(input, i);
		}
	}
}