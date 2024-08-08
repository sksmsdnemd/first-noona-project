
// function convertListToTree(list){
//
//     let copyList = [...list];
//     const toTreeItem = (item) => ({ ...item, children: [] });
//     const tree = list.filter((item) => item.pid === 0).map((item) => toTreeItem(item));
//
//     const addChildren = (parent) => {
//         const selected = [];
//         copyList = copyList.filter((child) => {
//             if(parent.id === child.pid){
//                 const treeItem = toTreeItem (child) ;
//                 parent.children.push(treeItem);
//                 selected.push(treeItem);
//                 return false;
//             }else{
//                 return true;
//             }
//         });
//         selected.forEach((parent) => addChildren(parent));
//     }
//     tree.forEach((parent) => addChildren(parent));
//
//     return tree;
//
// }

"use strict";

function ownKeys(object, enumerableOnly) {
    var keys = Object.keys(object);
    if (Object.getOwnPropertySymbols) {
        var symbols = Object.getOwnPropertySymbols(object);
        if (enumerableOnly)
            symbols = symbols.filter(function (sym) {
                return Object.getOwnPropertyDescriptor(object, sym).enumerable;
            });
        keys.push.apply(keys, symbols);
    }
    return keys;
}

function _objectSpread(target) {
    for (var i = 1; i < arguments.length; i++) {
        var source = arguments[i] != null ? arguments[i] : {};
        if (i % 2) {
            ownKeys(Object(source), true).forEach(function (key) {
                _defineProperty(target, key, source[key]);
            });
        } else if (Object.getOwnPropertyDescriptors) {
            Object.defineProperties(target, Object.getOwnPropertyDescriptors(source));
        } else {
            ownKeys(Object(source)).forEach(function (key) {
                Object.defineProperty(
                    target,
                    key,
                    Object.getOwnPropertyDescriptor(source, key)
                );
            });
        }
    }
    return target;
}

function _defineProperty(obj, key, value) {
    if (key in obj) {
        Object.defineProperty(obj, key, {
            value: value,
            enumerable: true,
            configurable: true,
            writable: true
        });
    } else {
        obj[key] = value;
    }
    return obj;
}

function _toConsumableArray(arr) {
    return (
        _arrayWithoutHoles(arr) ||
        _iterableToArray(arr) ||
        _unsupportedIterableToArray(arr) ||
        _nonIterableSpread()
    );
}

function _nonIterableSpread() {
    throw new TypeError(
        "Invalid attempt to spread non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method."
    );
}

function _unsupportedIterableToArray(o, minLen) {
    if (!o) return;
    if (typeof o === "string") return _arrayLikeToArray(o, minLen);
    var n = Object.prototype.toString.call(o).slice(8, -1);
    if (n === "Object" && o.constructor) n = o.constructor.name;
    if (n === "Map" || n === "Set") return Array.from(o);
    if (n === "Arguments" || /^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(n))
        return _arrayLikeToArray(o, minLen);
}

function _iterableToArray(iter) {
    if (typeof Symbol !== "undefined" && Symbol.iterator in Object(iter))
        return Array.from(iter);
}

function _arrayWithoutHoles(arr) {
    if (Array.isArray(arr)) return _arrayLikeToArray(arr);
}

function _arrayLikeToArray(arr, len) {
    if (len == null || len > arr.length) len = arr.length;
    for (var i = 0, arr2 = new Array(len); i < len; i++) {
        arr2[i] = arr[i];
    }
    return arr2;
}

function convertListToTree(list) {
    var copyList = _toConsumableArray(list);

    var toTreeItem = function toTreeItem(item) {
        return _objectSpread(
            _objectSpread({}, item),
            {},
            {
                children: []
            }
        );
    };

    var tree = list
        .filter(function (item) {
//            return item.pid === 0;
            return item.pid === "0";
        })
        .map(function (item) {
            return toTreeItem(item);
        });

    var addChildren = function addChildren(parent) {
        var selected = [];
        copyList = copyList.filter(function (child) {
            if (parent.id === child.pid) {
                var treeItem = toTreeItem(child);
                parent.children.push(treeItem);
                selected.push(treeItem);
                return false;
            } else {
                return true;
            }
        });
        selected.forEach(function (parent) {
            return addChildren(parent);
        });
    };

    tree.forEach(function (parent) {
        return addChildren(parent);
    });
    return tree;
}