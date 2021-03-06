/// Support for doing something awesome.
///
/// More dartdocs go here.
library tree;

export 'src/tree_base.dart';

// TODO: Export any libraries intended for clients of this package.

import 'package:uuid/uuid.dart';
import 'dart:math';

String MyUuid() {
  return Random().nextInt(100).toString();
}

class WithUuid {
  String _uuid;
  String _parentUuid;

  WithUuid() {
//    this._uuid = Uuid().v4();
    this._uuid = MyUuid();
  }

  String get uuid => _uuid;

  String get parentUuid => _parentUuid;
}

class TreeNode<D extends WithUuid> {
  D data;
  Map<String, TreeNode<D>> children;
  TreeNode<D> parent;

  TreeNode(this.data) : this.children = {};

  TreeNode<D> add(D newData) {
    //first search for the newData in tree, might already be added
//    print("add: trying to add ${newData.toString()} to parent ${newData.parentUuid}");
    TreeNode<D> found = findByUuid(newData.uuid);
    if (found != null) {
//      print("already in tree: ${newData.uuid}, parent is ${found.toString()}");
      return found;
    }

    //if newData not in tree
    // and parent should be the root node, add to this node
    if (newData.parentUuid == null) {
//      print("adding to root ${data?.uuid}");
      return addDirectDescendant(newData);
    }

    //if newData not in tree,
    // and parent should not be the root,
    // search for specified parent for newData
    TreeNode<D> foundParent = findByUuid(newData.parentUuid);
    if (foundParent != null) {
//      print("add direct to other node $foundParent");
      return foundParent.addDirectDescendant(newData);
    }

    //if the desired parent os not part of the tree, return null;
    return null;
  }

  TreeNode<D> addDirectDescendant(D newData) {
    TreeNode<D> child = TreeNode<D>(newData);
    child.parent = this;
    if (newData != null) this.children[newData.uuid] = child;
//    print("addDirectDescendant: added ${child.data} = {$newData} with uuid: ${child.data.uuid} to $this");
//    print("children: $children");

    return child;
  }

  TreeNode<D> findByUuid(String uuid) {
//    print("looking for uuid: $uuid in $this");
//    if (data==null) return null;
    if (uuid == null) return null;

    assert(uuid != null);
    if ((this.data != null) && (this.data.uuid == uuid)) {
//      print("IT IS ME!");
      return this;
    }
    for (var k in children.keys) {
      var found = children[k].findByUuid(uuid);
      if (found != null) {
//        print("found in child $k");
        return found;
      }
    }
//    print("not found");
    return null;
  }

  List<String> toStringList() {
    var res = <String>[];

//    res.add("Tree:");

    res.add((data != null ? "node ${data?.uuid}: $data" : "root") +
        " parent: " + (parent==null ? "null" : (parent.parent==null ? "root" : parent.data.uuid)) +
        " has ${children.length.toString()} children");

    this.children.forEach((String uuid, TreeNode t) {
      t.toStringList()
        ..forEach((String str) {
          res.add("    " + str);
        });
    });

    return res;
  }

  String toString() {
    return toStringList().join("\n");
  }

  factory TreeNode.fromList(List<D> categories) {
//    TreeNode<D> rootNode = TreeNode<D>(rootData);
    TreeNode<D> rootNode = TreeNode<D>(null);

    var unassigned = List<D>.from(categories);

    int iterations = 0;
    while (unassigned.length > 0 && iterations < categories.length) {
      print("ITERATION $iterations\n");
      iterations++;

      for (var category in categories) {
        if (!unassigned.contains(category)) {
          continue;
        }

//        print("unassigned: $category");
        var newNode = rootNode.add(category);

        if (newNode == null) {
//          print ("could NOT add $category");
        } else {
//          print ("added $category");
//          print ("Tree is: \n$this");
          unassigned.remove(category);
        }
      }
    }

//     print("ROOT: " + rootNode.toString() + "\n");
    return rootNode;
  }
}
