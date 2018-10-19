# Pharo2VW

This is an exporter from pharo source code to visualworks file with extention ".st", but this creates an XML that can be read by many smalltalks dialects.

## Prerequisites

You will need pharo6 up and visualworks 7.4 up

## Installing

In pharo playground execute the next piece of code

```Smalltalk
Metacello new
	baseline: 'Pharo2VW';
	repository: 'github://ObjectProfile/Pharo2VW/src';
	load.
```

## Getting Started

In your playground execute the next piece of code

```Smalltalk
Pharo2VW exporter
	namespace: 'MySpaceInVW';
	package: 'Pharo2VW';
	export.
```
This will create file `MySpaceInVW.st` in your pharo working directory. The file contains is an xml format that visualworks can open to load source code.

In the next example try to change the output directory with the selector: `directory:`, or define the external namespaces that your software needs to run. Also you can define what methods of your package tags, you do not want to export.

```Smalltalk
Pharo2VW exporter
	directory: FileSystem disk workingDirectory/'exports';
	namespace: 'MySpaceInVW';
	externalNamespaces: {'Roassal2'};
	methodsBlacklist: {Pharo2VWExamples >> #exampleExportRoassalWithoutSomeMethods};
	package: 'Pharo2VW';
	export.
```

Visualworks do not have the same array notation for {}. But do not worry this exporter export this `{'A'}` in this order `(Array new: 1) at: 1 put: 'A'`

### Loading the file in VisualWorks

After you get the file `MySpaceInVW.st` you can load it into a visualworks image

1. In this example, create a bundle called `MyBundle`, and add the package `MyPackage` in that bundle
2. For `MyPackage`, rightclick then select the option `File into...`.
3. Select the file `MySpaceInVW.st` and load it.
4. If you get some error loading the file. Delete the loaded code, and fix the problem in pharo. (Common errors: your code have some pharo things, etc )
5. At this point your code is loaded in visualworks all classes in the same package. Probably now you need the classes have the same package organization. In that case try to use the next piece of code.

```Smalltalk
| main classes cat pkg |
main := Registry bundleNamed: 'MyBundle'.
classes := main allClasses.
packages := Dictionary new.
classes do: [ :cls |  
	cat := cls myClass category asString.
	pkg := packages at: cat ifAbsentPut: [ | p |
		p := Registry packageNamedOrCreate: cat.
		main addItem: p.
		p ].
	XChangeSet current moveWholeClass: cls toPackage: pkg
```
6. Run the tests, you need to have many tests to ensure that you code works well in Visualworks like in pharo
7. In some cases you will need code that not exists in pharo. In that case you can create class extentions. In this example maybe we need to have a particular method of `Color` from pharo in `ColorValue` the color class in visualworks. So we can create an extention.
8. Create the package `MyPackage-extentions` then rightclick in the class area, and select `add class extention` for class `ColorValue`. With extentions you can add or override existing methods in visualworks, please try to avoid overrides in visualworks.
8. In case that you need a different class of visualworks like `DateAndTime` in pharo, but for visualworks that class is `Timestamp`. Maybe you will need a class `Platform` in order to idenfify when your system is running in pharo or in visualworks, to use the correct classes.
10. In case that you need to update your code. You will need to delete all the code and packages(except extentions) and load the process again. For that case use this example script.

```Smalltalk
| b notremove |
notremove := OrderedCollection new.
notremove add: 'MyPackage-extentions'.
b := Registry bundleNamed: 'MyBundle'.
b leafItems do: [ :pkg | 
  (notremove includes: pkg name) ifFalse: [
		pkg doUnloadFromImage.
]. 

```
11. In visualworks check that your source code do not have refereces to undefined objects, you can check this in you bundle tab `Prerequisites`
12. At this points, you have correct extentions, your classes are in the correct package, your tests are green, and you do not have references to undefined objects. Now you can upload you code to the public repository. Finally last point is check the bundle load order. you can see that in `Bundle Structure` tab. Try you use the next example to set the load order of your packages.

```Smalltalk
b := Registry bundleNamed: 'MyBundle'.
list := b containedItems.
r := list select: [:d | d name = 'MyPackage-extentions'].
list remove: r first.
list add: r first.
b containedItems: list.
```
13. Now publish your code and drink a glass of coffee!!

![Image of my old friend](https://i.pinimg.com/236x/e7/da/53/e7da53ee485ed608633be2d3b91caebf--coffee-meme-sayings.jpg)


Browse the `Pharo2VWExamples` in your system browser to get more examples

## Running the tests

Use test runner to execute the tests. `Pharo2VWExporterTest` execute all the examples in `Pharo2VWExamples`

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

# Contact
Feel free to add issues if you wish to have some requestion for enhancement, bug fixes, or bug description.
You can get in touch with us on discord (instruction on http://pharo.org/community), channel #Roassal


