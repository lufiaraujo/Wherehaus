import 'package:flutter/material.dart';
import 'testDataBase.dart';
import 'fileManager.dart';
import 'dart:async';
import 'dart:io';
import 'package:map_view/map_view.dart';
import 'getAPIKey.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:wherehous/dataObj.dart';
//import 'package:geolocation/geolocation.dart' as geo; 


Future<File> tempImage;
DataBase fakeOne;
int currentID;
String userName;
//geo.LocationResult tempLocation;
var staticMap;


void main()
{
	MapView.setApiKey(getAPIKey());
	staticMap = new StaticMapProvider(getAPIKey());
	runApp(new Wherehouse());
}

class Wherehouse extends StatelessWidget 
{
	@override
	Widget build(BuildContext context) 
	{
		fakeOne = new DataBase();
		currentID = 0;
		userName = "";
		
		return new MaterialApp
		(
			title: 'Wherehouse',
			theme: new ThemeData(primarySwatch: Colors.grey),
			home: new Home(title: 'Wherehouse'),
		);
	}
}

class Home extends StatefulWidget 
{
  	Home({Key key, this.title}) : super(key: key);
	final String title;

	@override
  	HomePage createState() => new HomePage();
}

class Search extends StatefulWidget 
{
  	Search({Key key, this.title}) : super(key: key);
	final String title;

	@override
  	SearchPage createState() => new SearchPage();
}

class Product extends StatefulWidget 
{
  	Product({Key key, this.title}) : super(key: key);
	final String title;

  	@override
  	ProductPage createState() => new ProductPage();
}

class Edit extends StatefulWidget 
{
  	Edit({Key key, this.title}) : super(key: key);
	final String title;

  	@override
  	EditPage createState() => new EditPage();
}

class NewEdit extends StatefulWidget 
{
  	NewEdit({Key key, this.title}) : super(key: key);
	final String title;

  	@override
  	NewEditPage createState() => new NewEditPage();
}

class Login extends StatefulWidget 
{

  	Login({Key key, this.title}) : super(key: key);
	final String title;

  	@override
  	LoginPage createState() => new LoginPage();
}

class HomePage extends State<Home>
{
	@override
	Widget build(BuildContext context) 
	{
		return new FutureBuilder<List<String>>
		(
			future: DataStorage.readIn(),
			builder: (BuildContext context, AsyncSnapshot<List<String>> userInfo) 
			{
				if (userInfo.connectionState != ConnectionState.done)
				{
					return new Container
					(
						color: Colors.white,
						alignment: Alignment.center,
						child: new Text
						(
							"loading...",
							style: new TextStyle
							(
								fontFamily: "RobotoMono",
								fontSize: 16.0,
								color: Colors.grey,
							),
						)
					);
				}
				else if (userInfo.data == []) 
				{
					return new Login();
				} 
				else if (userInfo.error == null)
				{
					//FIX: set vars here
					return new Search();
				}
				else 
				{
					
					showDialog(context:context, barrierDismissible: false, child: new SimpleDialog
					(
						title: new Text("An error occured"),
					));
					return new Center();
				} 
			},
		
		);
	}
}

class EditPage extends State<Edit> 
{
	final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
	final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

    List<String> productData = 
	[
		fakeOne.getDatabase()[currentID].getInfo(0),
		fakeOne.getDatabase()[currentID].getInfo(1),
		fakeOne.getDatabase()[currentID].getInfo(2),
		fakeOne.getDatabase()[currentID].getInfo(3),
		fakeOne.getDatabase()[currentID].getInfo(4),
		fakeOne.getDatabase()[currentID].getInfo(5),
		fakeOne.getDatabase()[currentID].getInfo(6),
		fakeOne.getDatabase()[currentID].getInfo(7),
		
	];

	List<bool> valid = 
    [
        false,
		false,
		false,
		false,
		false,
		false,
		false,
    ];

	List<FocusNode> focus =
	[
		new FocusNode(),
		new FocusNode(),
		new FocusNode(),
		new FocusNode(),
		new FocusNode(),
		new FocusNode(),
		new FocusNode(),
		new FocusNode(),
	];

	bool isNumeric(String s) 
	{
		if (s == '')
		{
			return true;
		}
		else if (s == null) 
		{
			return false;
    	}

    	return double.parse(s, (e) => null) != null;
  	}
	
	bool isValid()
	{
		bool output = true;

		for(int i = 0; i < valid.length; i++)
		{
			output = output && valid[i];
		}

		return output;
	}	

	Widget getFeild(String title, String hint, int id, bool empty, bool num)
	{
		return new Padding
		(
            padding: EdgeInsets.only(top: 16.0),
        	child: new ListTile
			(
                title: new Padding
				(
					padding: EdgeInsets.only(bottom: 8.0),
					child: new Text
					(
						'$title:', 
						style: new TextStyle
						(
							fontFamily: 'RobotoMono',
							fontWeight: FontWeight.bold,
							fontSize: 12.0,
						),
					),
                ),

                subtitle: new TextFormField
				(
					focusNode: focus[id],
                	initialValue: productData[id],
					autocorrect: true,
					autovalidate: true,

					style: new TextStyle
					(
						color: Colors.black,
						fontFamily: "RobotoMono",
						fontSize: 16.0,
					),

                    decoration: new InputDecoration
					(
						fillColor: Colors.grey[200],
						filled: true,
                    	hintText: hint,
						hintStyle: new TextStyle
						(
							color: Colors.grey[400],
							fontFamily: "RobotoMono",
							fontSize: 16.0,
						)
                    ),

                    validator: (value) 
					{
                    	if (value.isEmpty && empty) 
						{
							valid[id] = false;
                        	return 'Inventory must have a $title';
                        }
						else if (!isNumeric(value) && num)
						{
							valid[id] = false;
							return 'Must be a number';
                        }
						
						valid[id] = true;
						_formKey.currentState.save();
                    },

					onSaved: (value)
					{
						productData[id] = value;
					},

					onFieldSubmitted: (value) 
					{
						FocusScope.of(context).requestFocus(focus[id+1]);
					},

					keyboardType: num? new TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
					
                ),
            ),
        );
	}

	Form getForm()
	{
		return new Form
		(
			key: _formKey,
			child: new Column
			(
				children: <Widget>
				[
					getFeild("Title", "eg: 'Example", 0, true, false),
					getFeild("Product Number", "eg: '123456'", 1, true, true),
					getFeild("Location", "eg: 'warehouse'", 2, true, false),
					getFeild("Spot", "eg: '6'", 3, false, true),
					getFeild("Quantity", "eg: '200'", 4, true, true),
					getFeild("Tear Weight", "eg: '500'", 5, true, true),
					getFeild("Total Weight", "eg: '670'", 6, true, true),
				]
			)
		);
	}

	@override
	Widget build(BuildContext context) 
	{
		return new Scaffold
		(
			key: _scaffoldKey,

			body: new ListView
			(
				children: <Widget>
				[
					new Padding
					( //TITLE
						padding: EdgeInsets.all(16.0),
						child: new Row
						(
							mainAxisAlignment: MainAxisAlignment.start,
							crossAxisAlignment: CrossAxisAlignment.start,
							children: <Widget>
							[
								new IconTheme
								(
									data: new IconThemeData(size: 28.0),
									child: Icon(Icons.short_text)
								),

								new Text
								(
									' Edit',
									style: new TextStyle
									(
										fontWeight: FontWeight.bold,
										fontSize: 20.0,
										fontFamily: "RobotoMono",
									),
								)
							],
						),
					),

					getForm(),
				],
			),

			floatingActionButton: new FloatingActionButton
			(
				onPressed: ()
				{
					final fail = new SnackBar(content: new Text('Error: Some of the data is invalid'));
					
					if (isValid())
					{
						fakeOne.getDatabase()[currentID].editInfo(0, productData[0]);
						fakeOne.getDatabase()[currentID].editInfo(1, productData[1]);
						fakeOne.getDatabase()[currentID].editInfo(2, productData[2]);
						fakeOne.getDatabase()[currentID].editInfo(3, productData[3]);
						fakeOne.getDatabase()[currentID].editInfo(4, productData[4]);
						fakeOne.getDatabase()[currentID].editInfo(5, productData[5]);
						fakeOne.getDatabase()[currentID].editInfo(6, productData[6]);
						fakeOne.getDatabase()[currentID].editInfo(7, userName);
						//FIX update database

						//exit edit page:
						Navigator.pop(context);
					}
					else
					{
						_scaffoldKey.currentState.showSnackBar(fail);
					}
				},
				tooltip: 'Save',
				child: new Icon(Icons.check),
				backgroundColor: Colors.green,
				foregroundColor: Colors.white,
			),
		);
	}
}

class NewEditPage extends State<NewEdit> 
{
	final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
	final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<Item> items = List();
  Item item;
  DatabaseReference itemRef;
  //FirebaseStorage storage;
  Future<File> tempImage;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    item = Item('Empty','Empty','Empty','Empty','Empty','Empty','Empty','Empty',true, null);
    final FirebaseDatabase database = FirebaseDatabase.instance; //Rather then just writing FirebaseDatabase(), get the instance.  
    //final FirebaseStorage storage = FirebaseStorage.instance;
    //bucket = storage.storageBucket;
    itemRef = database.reference().child('items');
    itemRef.onChildAdded.listen(_onEntryAdded);
    itemRef.onChildChanged.listen(_onEntryChanged);
  }

  _onEntryAdded(Event event) {
    setState(() {
      items.add(Item.fromSnapshot(event.snapshot));
    });
  }

  _onEntryChanged(Event event) {
    var old = items.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    setState(() {
      items[items.indexOf(old)] = Item.fromSnapshot(event.snapshot);
    });
  }

 void handleSubmit() {
    final FormState form = formKey.currentState;

    if (form.validate()) {
      //item.image = tempImage;
      itemRef.push().set(item.toJson()); // imp
    }
  }

    List<String> productData = 
	[
		"",
		"",
		"",
		"",
		"",
		"",
		"",
	];

	List<bool> valid = 
    [
        false,
		false,
		false,
		false,
		false,
		false,
		false,
    ];

	List<FocusNode> focus =
	[
		new FocusNode(),
		new FocusNode(),
		new FocusNode(),
		new FocusNode(),
		new FocusNode(),
		new FocusNode(),
		new FocusNode(),
		new FocusNode(),
	];

	bool isNumeric(String s) 
	{
		if (s == '')
		{
			return true;
		}
		else if (s == null) 
		{
			return false;
    	}

    	return double.parse(s, (e) => null) != null;
  	}
	
	bool isValid()
	{
		bool output = true;

		for(int i = 0; i < valid.length; i++)
		{
			output = output && valid[i];
		}

		return output;
	}	

	Widget getFeild(String title, String hint, int id, bool empty, bool num)
	{
		return new Padding
		(
            padding: EdgeInsets.only(top: 16.0),
        	child: new ListTile
			(
                title: new Padding
				(
					padding: EdgeInsets.only(bottom: 8.0),
					child: new Text
					(
						'$title:', 
						style: new TextStyle
						(
							fontFamily: 'RobotoMono',
							fontWeight: FontWeight.bold,
							fontSize: 12.0,
						),
					),
                ),

                subtitle: new TextFormField
				(
					focusNode: focus[id],
                	initialValue: productData[id],
					autocorrect: true,
					autovalidate: true,

					style: new TextStyle
					(
						color: Colors.black,
						fontFamily: "RobotoMono",
						fontSize: 16.0,
					),

                    decoration: new InputDecoration
					(
						fillColor: Colors.grey[200],
						filled: true,
                    	hintText: hint,
						hintStyle: new TextStyle
						(
							color: Colors.grey[400],
							fontFamily: "RobotoMono",
							fontSize: 16.0,
						)
                    ),

                    validator: (value) 
					{
                    	if (value.isEmpty && empty) 
						{
							valid[id] = false;
                        	return 'Inventory must have a $title';
                        }
						else if (!isNumeric(value) && num)
						{
							valid[id] = false;
							return 'Must be a number';
                        }
						
						valid[id] = true;
						_formKey.currentState.save();
                    },

					onSaved: (value)
					{
						productData[id] = value;
					},

					onFieldSubmitted: (value) 
					{
						FocusScope.of(context).requestFocus(focus[id+1]);
					},

					keyboardType: num? new TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
					
                ),
            ),
        );
	}

	Form getForm()
	{
		return new Form
		(
			key: _formKey,
			child: new Column
			(
				children: <Widget>
				[
					getFeild("Title", "eg: 'Example", 0, true, false),
					getFeild("Product Number", "eg: '123456'", 1, true, true),
					getFeild("Location", "eg: 'warehouse'", 2, true, false),
					getFeild("Spot", "eg: '6'", 3, false, true),
					getFeild("Quantity", "eg: '200'", 4, true, true),
					getFeild("Tear Weight", "eg: '500'", 5, true, true),
					getFeild("Total Weight", "eg: '670'", 6, true, true),
				]
			)
		);
	}

	@override
	Widget build(BuildContext context) 
	{
		return new Scaffold
		(
			key: _scaffoldKey,

			body: new ListView
			(
				children: <Widget>
				[
					new Padding
					( //TITLE
						padding: EdgeInsets.all(16.0),
						child: new Row
						(
							mainAxisAlignment: MainAxisAlignment.start,
							crossAxisAlignment: CrossAxisAlignment.start,
							children: <Widget>
							[
								new IconTheme
								(
									data: new IconThemeData(size: 28.0),
									child: Icon(Icons.short_text)
								),

								new Text
								(
									' Edit',
									style: new TextStyle
									(
										fontWeight: FontWeight.bold,
										fontSize: 20.0,
										fontFamily: "RobotoMono",
									),
								)
							],
						),
					),

					getForm(),
				],
			),

			floatingActionButton: new FloatingActionButton
			(
				onPressed: ()
				{
					final fail = new SnackBar(content: new Text('Error: Some of the data is invalid'));
					
					if (isValid())
					{
						currentID = fakeOne.getDatabase().length;
            item.title = productData[0];
            item.productNumber = productData[1];
            item.location = productData[2];
            item.position = productData[3];
            item.quantity = productData[4];
            item.tearWeight = productData[5];
            item.totalWeight = productData[6];
						// fakeOne.newItem
						// (
						// 	title: productData[0],
						// 	productNumber: productData[1],
						// 	location: productData[2],
						// 	position: productData[3],
						// 	quantity: productData[4],
						// 	tearWeight: productData[5],
						// 	totalWeight: productData[6],
						// 	lastEdit: userName,
						// 	image: tempImage,
						// 	//newGps: tempLocation,
						// );

						//exit edit page:
            itemRef.push().set(item.toJson());
						Navigator.pop(context);
						Navigator.push
						(
							context, 
							new MaterialPageRoute(builder: (context) => new Product()),
						);
					}
					else
					{
						_scaffoldKey.currentState.showSnackBar(fail);
					}
				},
				tooltip: 'Save',
				child: new Icon(Icons.check),
				backgroundColor: Colors.green,
				foregroundColor: Colors.white,
			),
		);
	}
}

class ProductPage extends State<Product> 
{
	MapView mapView = new MapView();
	CameraPosition cameraPosition;
	var staticMapProvider = new StaticMapProvider(getAPIKey());
	Uri staticMapUri;
	//Location loc;

	@override
	initState() 
	{
		super.initState();
		// if(fakeOne.getDatabase()[currentID].getLat() == null || fakeOne.getDatabase()[currentID].getLong() == null)
		// {
		// 	loc = null;
		// }
		// else
		// {
		// 	loc = new Location(fakeOne.getDatabase()[currentID].getLat(), fakeOne.getDatabase()[currentID].getLong());
		// }

		//cameraPosition = new CameraPosition(loc, 2.0);
		//staticMapUri = staticMapProvider.getStaticUri(loc, 19, width: 900, height: 400, mapType: StaticMapViewType.roadmap); //FIX: set to 20 if more zoom is needed
	}
	
    RichText getData(String title, int id)
    {
        int totalLength = 13;
        String space = '';

        for (int i = title.length; i < totalLength; i++)
        {
            space = space + ' ';
        }

        return new RichText
        (
            text: new TextSpan
            (
                text: '$title:$space',

                style: new TextStyle
                (
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                    fontFamily: 'RobotoMono',
                    color: Colors.black,
                ),

                children: <TextSpan>
                [
                    new TextSpan
                    (
                        text: fakeOne.getDatabase()[currentID].getInfo(id), 
                        style: new TextStyle(fontWeight: FontWeight.normal)
                    ),
                ],
            ),
        );
    }

    @override
    Widget build(BuildContext context) 
    {
        return new Scaffold
        (
			//appBar: new AppBar
			//(
				
			//),

            body: new ListView
            (
                children: <Widget>
                [
                    new Container //HERO
                    ( 
                        height: 250.0, //height of img
                        width: MediaQuery.of(context).size.width,
                        color: Colors.grey[300],
                        
                        child: new Stack //img, back button
                        (
                            children: <Widget>
                            [
                                new FutureBuilder<File>
								(
									future: fakeOne.getDatabase()[currentID].getImage(),
									builder: (BuildContext context, AsyncSnapshot<File> snapshot) 
									{
										if (snapshot.connectionState == ConnectionState.done &&
											snapshot.data != null) 
										{
											return new Container //HERO
											( 
												height: 250.0, //height of img
												width: MediaQuery.of(context).size.width,
												child: new Image.file
												(
													snapshot.data,
													fit: BoxFit.cover,
												)
											);
										} 
										else if (snapshot.error != null) 
										{
											return new InkWell
											(
												onTap: ()
												{
													tempImage = ImagePicker.pickImage(source: ImageSource.camera);
													fakeOne.getDatabase()[currentID].setImage(tempImage);
													Navigator.pushReplacement
													(
														context,
														new MaterialPageRoute(builder: (context) => new Product()),
													);
												},

												child: new Center
												(
													child: Text
													(
														'error picking image.',
														style: new TextStyle
														(
															color: Colors.grey,
															fontFamily: "RobotoMono",
															fontSize: 16.0,
														)
													),
												),
											);
										} 
										else 
										{
											return new InkWell
											(
												onTap: ()
												{
													tempImage = ImagePicker.pickImage(source: ImageSource.camera);
													fakeOne.getDatabase()[currentID].setImage(tempImage);
													Navigator.pushReplacement
													(
														context,
														new MaterialPageRoute(builder: (context) => new Product()),
													);
												},

												child: new Center
												(
													child: Text(
														'You have not yet picked an image.',
														style: new TextStyle
														(
															color: Colors.grey,
															fontFamily: "RobotoMono",
															fontSize: 16.0,
														)
													),
												),
											);
										}
									},
                                
                             	),

								new Padding //shadow
								(
									padding: EdgeInsets.only(top: 2.0),
									child: new ListTile
									(
										leading: new BackButton
										(
											color: Colors.black38,
										),
									),
								),

								new ListTile
								(
									leading: new BackButton
									(
										color: Colors.white,
									),
								),
                            ],
                        )
                    ),

                    new Padding //TITLE
                    ( 
                        padding: EdgeInsets.only(top: 24.0, left: 36.0),
                        child: new Text
                        (
                            '${fakeOne.getDatabase()[currentID].getInfo(0)}',
                            style: new TextStyle
                            (
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                                fontFamily: "RobotoMono",
                            ),
                        ),
                    ),

                    new Padding //PRODUCT #
                    ( 
                        padding: EdgeInsets.only(left: 36.0, top: 4.0),
                        child: new Text
                        (
                            '# ${fakeOne.getDatabase()[currentID].getInfo(1)}',
                            style: new TextStyle
                            (
                                color: Colors.grey[500],
                                fontSize: 16.0,
                                fontFamily: 'RobotoMono',
                            ),
                        ),
                    ),

                    new Padding //BUTTONS
                    ( 
                        padding: EdgeInsets.symmetric(vertical: 24.0),
                        child: new Row
                        (
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,

                            children: <Widget>
                            [
                                new Column //EDIT
                                (
                                    children: <Widget>
                                    [
                                        new IconButton
                                        (
                                            icon: new Icon(Icons.edit),
                                            color: Colors.blue,
                                            onPressed: ()
                                            {
                                                Navigator.push
                                                (
                                                    context,
                                                    new MaterialPageRoute(builder: (context) => new Edit()),
                                                );
                                            },
                                        ),

                                        new Text
                                        (
                                            'EDIT',
                                            style: new TextStyle
                                            (
                                                fontWeight: FontWeight.w600,
                                                color: Colors.blue,
                                                fontSize: 14.0,
                                            ),
                                        ),
                                    ],
                                ),

                                new Column //MOVE
                                (
                                    children: <Widget>
                                    [
                                        new IconButton
                                        (
                                            icon: new Icon(Icons.open_with),
                                            color: Colors.blue,
                                            onPressed: () //FIX (more specilized)
                                            {
                                                Navigator.push
                                                (
                                                    context,
                                                    new MaterialPageRoute(builder: (context) => new Edit()),
                                                );
                                            },
                                        ),
                                        
                                        new Text
                                        (
                                            'MOVE',
                                            style: new TextStyle
                                            (
                                                fontWeight: FontWeight.w600,
                                                color: Colors.blue,
                                                fontSize: 14.0,
                                            ),
                                        ),
                                    ],
                                ),
                            
                                new Column //CLEAR
                                (
                                    children: <Widget>
                                    [
                                        new IconButton
                                        (
                                            icon: new Icon(Icons.clear),
                                            color: Colors.blue,
                                            onPressed: ()
                                            {
                                                showDialog
												(
													context: context, 
													child: new AlertDialog
													(
														title: new Text("Are you sure?"),
														content: new Text("Deleting this item is permenant and cannot be undone."),
														actions: <Widget>
														[
															new FlatButton
															(
																child: new Text
																(
																	"DELETE", 
																	style: new TextStyle(color: Colors.blue)
																),

																onPressed: ()
																{
																	fakeOne.delete(currentID);
																	Navigator.pop(context);
																	Navigator.pop(context);
																},
															),

															new FlatButton
															(
																child: new Text
																(
																	"CANCEL", 
																	style: new TextStyle(color: Colors.blue)
																),

																onPressed: ()
																{
																	Navigator.pop(context);
																},
															)
														],
													)
												);
                                            }, 
                                        ),

                                        new Text
                                        (
                                            'CLEAR',
                                            style: new TextStyle
                                            (
                                                fontWeight: FontWeight.w600,
                                                color: Colors.blue,
                                                fontSize: 14.0,
                                            ),
                                        ),
                                    ],
                                ),
                            ],
                        ),
                    ),

                    new Padding //DATA
                    (
                        padding: EdgeInsets.only(left: 36.0, top: 24.0, bottom: 36.0),
                        child: new Column
                        (
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: <Widget>
                            [
                                getData('name', 0),
                                getData('number', 1),
                                getData('location', 2),
                                getData('position', 3),
                                getData('quantity', 4),
                                getData('tear weight', 5),
                                getData('total weight', 6),
                                getData('last seen', 7),
                            ],
                        )
                    ),

                    new Container //MAP
                    ( 
                        height: 300.0, //hight of img
                        width: MediaQuery.of(context).size.width,
                        color: Colors.grey,
                        
                        child: new Image.network
						(
							staticMapUri.toString(),
							fit: BoxFit.cover,
						),
                    ),
                ],
            ),
        );
    }
}

class SearchPage extends State<Search> 
{
	final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
	String searchInput = "";
  //StreamSubscription<geo.LocationResult> locationStream;

	@override
	initState()
	{
		super.initState();
		//checkGps();
	}

	// checkGps() async
	// {
	// 	final geo.GeolocationResult result = await geo.Geolocation.requestLocationPermission(const geo.LocationPermission
	// 	(
	// 		android: geo.LocationPermissionAndroid.fine,
	// 		ios: geo.LocationPermissionIOS.always,
	// 	));

	// 	if (result.isSuccessful)
	// 	{
	// 		print("Success");
	// 	}  
	// 	else
	// 	{
	// 		print("Failed");
	// 	}
	// }
	
  
	Widget getResult(int index)
	{
		return new ListTile
		(
			onTap: () 
			{
				currentID = index;

				Navigator.push
				(
					context,
					new MaterialPageRoute(builder: (context) => new Product()),
				);
			},

			leading: new FutureBuilder<File>
			(
				future: fakeOne.getDatabase()[index].getImage(),
				builder: (BuildContext context, AsyncSnapshot<File> snapshot) 
				{
					if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) 
					{
						return new Container
						(
							height: 40.0,
							width: 40.0,
							child: new Image.file
							(
								snapshot.data,
								fit: BoxFit.cover,
							)
						);
					} 
					else
					{
						return new Placeholder
						(
							fallbackHeight: 40.0,
							strokeWidth: 1.0,
							color: Colors.grey,
						);
					} 
				}
			),

			title: new Padding
			(
				padding: EdgeInsets.only(left: 16.0),
				child: new Text
				(
					'${fakeOne.getDatabase()[index].getInfo(0)}',
					style: new TextStyle
					(
						fontWeight: FontWeight.bold,
						fontSize: 16.0,
						color: Colors.black,
						fontFamily: "RobotoMono",
					),
				),
			),

			subtitle: new Padding
			(
				padding: EdgeInsets.only(left: 16.0),
				child: new Text
				(
					'${fakeOne.getDatabase()[index].getInfo(2)}',
					style: new TextStyle
					(
						fontSize: 16.0,
						color: Colors.grey,
						fontFamily: "RobotoMono",
					),
				),
			),
		);
	}

	Widget getNoResults()
	{
		return new Center
		(
			child: new Padding
			(
				padding: EdgeInsets.only(top: 100.0),
				child: new Column
				(
					mainAxisAlignment: MainAxisAlignment.center,
					
					children: <Widget>
					[
						new Image.asset('assets/no_results.png'),

						new Text
						(
							"No Results",
							style: new TextStyle
							(
								fontFamily: "RobotoMono",
								fontSize: 16.0,
								color: Colors.grey[700],
								fontWeight: FontWeight.bold,
							),
						),

						new Text
						(
							"Try a diffrent search term",
							style: new TextStyle
							(
								fontFamily: "RobotoMono",
								fontSize: 16.0,
								color: Colors.grey[600],
							),
						),
					],
				),
			)
		);
	}

	Widget getProducts() 
	{
		List<Widget> list = new List();
		fakeOne.update(searchInput);

		for (int i = 0; i < fakeOne.getSearch().length; i++)
		{
			list.add
			(
				getResult(fakeOne.getSearch()[i])
			);
		}

		if (list.length == 0)
		{
			return getNoResults();
		}

		return new Card
		(
			margin: EdgeInsets.all(8.0),
			elevation: 2.0,
			child: new Column
			(
				mainAxisAlignment: MainAxisAlignment.start,
				crossAxisAlignment: CrossAxisAlignment.start,
				children: list,
			),
		);
	}

	@override
	Widget build(BuildContext context) 
	{
		return new Scaffold
		(
			backgroundColor: Colors.grey[200],
			appBar: new PreferredSize
			(
				preferredSize: new Size(MediaQuery.of(context).size.width, 56.0),
				child: new ListView
				(
					children: <Widget>
					[
						new Card //SEARCH
						(
							margin: EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
							elevation: 6.0,
							child: new Row
							(
								mainAxisAlignment: MainAxisAlignment.start,
								crossAxisAlignment: CrossAxisAlignment.center,

								children: <Widget>
								[
									new IconButton
									(
										icon: new Icon(Icons.search),
										color: Colors.grey[600],
										onPressed: ()
										{
											FocusScope.of(context).requestFocus(new FocusNode());
										},
									),

									new Flexible
									(
										child: new Form
										(
											key: _formKey,
											onChanged: ()
											{
												fakeOne.update(searchInput);
											},

											child: new TextFormField
											(
												autocorrect: true,
												autovalidate: true,

												style: new TextStyle
												(
													color: Colors.black,
													fontSize: 16.0,
													fontFamily: "RobotoMono",
												),

												decoration: new InputDecoration
												(
													border: InputBorder.none,
													hintText: 'Search',
													hintStyle: new TextStyle
													(
														color: Colors.grey,
														fontSize: 16.0,
														fontFamily: "RobotoMono",
													)
												),

												validator: (value)
												{
													searchInput = value;
												},
											),
										),
									),
								],
							),	
				  		),
					],
				),
			),

			body: new RefreshIndicator
			(
				color: Colors.blue,
				onRefresh: ()
				{
					final Completer<Null> completer = new Completer<Null>();
					new Timer(const Duration(seconds: 3), () 
					{ 
						completer.complete(null); 
					});

					return completer.future.then((_) 
					{
						print("REFRESHED");
					});
					//FIX: refresh database
				},

				child: new ListView
				(
					children: <Widget>
					[
						getProducts(),
					],
				),
			),

			floatingActionButton: new FloatingActionButton
			(
				onPressed: ()
				{
					// locationStream = geo.Geolocation.currentLocation(accuracy: geo.LocationAccuracy.best).listen((locResult)
					// {
					// 	tempLocation = locResult;
					// 	// create property in item object for storing location
					// });

					tempImage = ImagePicker.pickImage(source: ImageSource.camera);
					Navigator.push
					(
						context,
						new MaterialPageRoute(builder: (context) => new NewEdit()),
					);
				},

				tooltip: 'Add new',
				child: new Icon(Icons.add),
				backgroundColor: Colors.blue,
				foregroundColor: Colors.white,
			),
		);
	}

}

class LoginPage extends State<Login>
{
	final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
	bool isValid = false;
	List<String> userData = 
	[
		"",
		"",
		"",
		"",
	];

	void setUserInfo()
	{
		DataStorage file = new DataStorage();
		file.writeData(userData.join("\n"));
		userName = userData[0];
		//set sql vars here FIX
	}

	void testConnection()
	{
		//make sure sql credentials are correct
		if(userData[2].isNotEmpty)
		{
			isValid = true;
		}
	}

    @override
    Widget build(BuildContext context) 
    {
        return new Scaffold
        (
            body: new ListView
			(
				children:<Widget>
				[
					new Column
					(
						mainAxisAlignment: MainAxisAlignment.center,
						crossAxisAlignment: CrossAxisAlignment.center,
						children: <Widget>
						[
							new Padding
							( //TITLE
								padding: EdgeInsets.only(top: 64.0, left: 16.0, right: 16.0, bottom: 16.0),
								child: new Row
								(
									mainAxisAlignment: MainAxisAlignment.start,
									crossAxisAlignment: CrossAxisAlignment.start,
									children: <Widget>
									[
										new IconTheme
										(
											data: new IconThemeData(size: 28.0),
											child: Icon(Icons.person_add),
										),

										new Text
										(
											' Login In',
											style: new TextStyle
											(
												fontWeight: FontWeight.bold,
												fontSize: 20.0,
												fontFamily: "RobotoMono",
											),
										)
									],
								),
							),

							new Form
							(
								key: _formKey,
								child: new Column
								(
									children: <Widget>
									[
										new Padding
										(
											padding: EdgeInsets.only(top: 16.0),
											child: new ListTile
											(
												title: new Padding
												(
													padding: EdgeInsets.only(bottom: 8.0),
													child: new Text
													(
														'Username:', 
														style: new TextStyle
														(
															fontFamily: 'RobotoMono',
															fontWeight: FontWeight.bold,
															fontSize: 12.0,
														),
													),
												),

												subtitle: new TextFormField
												(
													autocorrect: true,

													style: new TextStyle
													(
														color: Colors.black,
														fontFamily: "RobotoMono",
														fontSize: 16.0,
													),

													decoration: new InputDecoration
													(
														fillColor: Colors.grey[200],
														filled: true,
														hintText: "Eg: 'Ron Smith'",
														hintStyle: new TextStyle
														(
															color: Colors.grey[400],
															fontFamily: "RobotoMono",
															fontSize: 16.0,
														)
													),

													validator: (value)
													{
														if (value.isEmpty)
														{
															return "A username is required";
														}
													},

													onSaved: (value)
													{
														userData[0] = value;
													},
												),
											),
										),

										new Padding
										(
											padding: EdgeInsets.only(top: 32.0),
											child: new ListTile
											(
												title: new Padding
												(
													padding: EdgeInsets.only(bottom: 8.0),
													child: new Text
													(
														'Server Address:', 
														style: new TextStyle
														(
															fontFamily: 'RobotoMono',
															fontWeight: FontWeight.bold,
															fontSize: 12.0,
														),
													),
												),

												subtitle: new TextFormField
												(
													autocorrect: false,

													style: new TextStyle
													(
														color: Colors.black,
														fontFamily: "RobotoMono",
														fontSize: 16.0,
													),

													decoration: new InputDecoration
													(
														fillColor: Colors.grey[200],
														filled: true,
													),

													validator: (value)
													{
														if (!isValid)
														{
															return "Credentials invalid";
														}
													},

													onSaved: (value)
													{
														userData[1] = value;
													},
												),
											),
										),

										new Padding
										(
											padding: EdgeInsets.only(top: 16.0),
											child: new ListTile
											(
												title: new Padding
												(
													padding: EdgeInsets.only(bottom: 8.0),
													child: new Text
													(
														'Server Username:', 
														style: new TextStyle
														(
															fontFamily: 'RobotoMono',
															fontWeight: FontWeight.bold,
															fontSize: 12.0,
														),
													),
												),

												subtitle: new TextFormField
												(
													autocorrect: false,

													style: new TextStyle
													(
														color: Colors.black,
														fontFamily: "RobotoMono",
														fontSize: 16.0,
													),

													decoration: new InputDecoration
													(
														fillColor: Colors.grey[200],
														filled: true,
													),

													validator: (value)
													{
														if (!isValid)
														{
															return "Credentials invalid";
														}
													},

													onSaved: (value)
													{
														userData[2] = value;
													},
												),
											),
										),

										new Padding
										(
											padding: EdgeInsets.only(top: 16.0),
											child: new ListTile
											(
												title: new Padding
												(
													padding: EdgeInsets.only(bottom: 8.0),
													child: new Text
													(
														'Server Password:', 
														style: new TextStyle
														(
															fontFamily: 'RobotoMono',
															fontWeight: FontWeight.bold,
															fontSize: 12.0,
														),
													),
												),

												subtitle: new TextFormField
												(
													autocorrect: false,

													style: new TextStyle
													(
														color: Colors.black,
														fontFamily: "RobotoMono",
														fontSize: 16.0,
													),

													decoration: new InputDecoration
													(
														fillColor: Colors.grey[200],
														filled: true,
													),

													validator: (value)
													{
														if (!isValid)
														{
															return "Credentials invalid";
														}
													},

													onSaved: (value)
													{
														userData[3] = value;
													},
												),
											),
										),

										new Padding
										(
											padding: EdgeInsets.all(32.0),
											child: new FloatingActionButton.extended
											(
												backgroundColor: Colors.blue,
												icon: new Icon(Icons.send, color: Colors.white),
												label: new Padding
												(
													padding: EdgeInsets.symmetric(horizontal: 16.0),
													child: new Text
													(
														"Login", 
														style: new TextStyle
														(
															color: Colors.white,
															fontFamily: "RobotoMono",
															fontSize: 16.0,
														),
													),
												),
												
												onPressed: () 
												{
													_formKey.currentState.save();
													testConnection();
													if (_formKey.currentState.validate())
													{
														setUserInfo();
														Navigator.pushReplacement
														(
															context,
															new MaterialPageRoute(builder: (context) => new Home()),
														);
													}
												},
											),
										)
									]
								)
							),
						],
					),
				],
            ),
        );
    }
}
