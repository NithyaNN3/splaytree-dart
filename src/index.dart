typedef Comparator<T> = int Function(T a, T b);
typedef Predicate<T> = bool Function(T value);
typedef SplayTreeMapWrapper<K, V> = SplayTreeWrapper<K, SplayTreeMapNode<K, V>>;

class SplayTreeNode<K, Node extends SplayTreeNode<K, Node>> {
    final K key; 
    
    Node? left;
    Node? right;

    SplayTreeNode(this.key);
}

class SplayTreeSetNode<K> extends SplayTreeNode<K, SplayTreeSetNode<K>>{
    SplayTreeSetNode(K key) : super(key);
}

class SplayTreeMapNode<K, V> extends SplayTreeNode<K, SplayTreeMapNode<K, V>> {
    final value: V;

    SplayTreeMapNode(K key, V value) : super(key);

    SplayTreeMapNode<K, V> replaceValue(V value) {
        final node = SplayTreeMapNode<K, V>(this.key, value);
        node.left = this.left;
        node.right = this.right;
        return node;
    }

}

// SplayTreeWrapper class 
class SplayTreeWrapper<K, N> {
    final N? Function() getRoot;
    final void Function(N?) setRoot;
    final int Function() getSize;
    final int Function() getModificationCount;
    final int Function() getSplayCount;
    final void Function(int) setSplayCount;
    final int Function(K) splay;
    final bool Function(dynamic) has;

    SplayTreeWrapper({
        required this.getRoot,
        required this.setRoot,
        required this.getSize,
        required this.getModificationCount,
        required this.getSplayCount,
        required this.setSplayCount,
        required this.splay,
        required this.has,
    });
}

abstract class SplayTree<K, Node extends SplayTreeNode<K, Node>> {
    Node? root;

    int size = 0;

    int modificationCount = 0;

    int splayCount = 0;

    Comparator<K> get compare;

    Predicate<Object>> get validKey;

    int splay(K key) {
        final root = this.root;
        if (root == null) {
            this.compare(key, key);
            return -1;
        }
        
        Node? right = null;
        Node? newTreeRight = null;
        Node? left = null;
        Node? newTreeLeft = null;
        Node current = root;
        final compare = this.compare;
        int comp;
        
        while (true) {
            comp = compare(current.key, key);
            if (comp > 0) {
            Node? currentLeft = current.left;
            if (currentLeft == null) break;
            comp = compare(currentLeft.key, key);
            if (comp > 0) {
                current.left = currentLeft.right;
                currentLeft.right = current;
                current = currentLeft;
                currentLeft = current.left;
                if (currentLeft == null) break;
            }
            if (right == null) {
                newTreeRight = current;
            } else {
                right.left = current;
            }
            right = current;
            current = currentLeft!;
            } else if (comp < 0) {
            Node? currentRight = current.right;
            if (currentRight == null) break;
            comp = compare(currentRight.key, key);
            if (comp < 0) {
                current.right = currentRight.left;
                currentRight.left = current;
                current = currentRight;
                currentRight = current.right;
                if (currentRight == null) break;
            }
            if (left == null) {
                newTreeLeft = current;
            } else {
                left.right = current;
            }
            left = current;
            current = currentRight!;
            } else {
            break;
            }
        }
        
        if (left != null) {
            left.right = current.left;
            current.left = newTreeLeft;
        }
        if (right != null) {
            right.left = current.right;
            current.right = newTreeRight;
        }
        
        if (this.root != current) {
            this.root = current;
            this.splayCount++;
        }
        
        return comp;
    }

    Node splayMin(Node node) {
        Node current = node;
        Node? nextLeft = current.left;
        while (nextLeft != null) {
            final left = nextLeft;
            current.left = left.right;
            left.right = current;
            current = left;
            nextLeft = current.left;
        }
        return current;
    }

    Node splayMax(Node: node) {
        Node current = node;
        Node? nextRight = current.right;
        while (nextRight != null) {
            final right = nextRight;
            current.right = right.left;
            right.left = current;
            current = right;
            nextRight = current.right;
        }
        return current;
    }

    Node? _delete(K key) {
        if (this.root == null) return null;
        final comp = this.splay(key);
        if (comp != 0) return null;


        Node root = this.root;
        final result = root;
        final Node? left = root.left;
        this.size--;


        if (left == null) {
            this.root = root.right;
        } else {
            final right = root.right;
            root = this.splayMax(left);

            root.right = right;
            this.root = root;
        }
        this.modificationCount++;
        return result;
    }

    void addNewRoot(Node node, int comp) {
        size++;
        modificationCount++;
        final root = this.root;
        if (root == null) {
            this.root = node;
            return;
        }
        if (comp < 0) {
            node.left = root;
            node.right = root.right;
            root.right = null;
        } else {
            node.right = root;
            node.left = root.left;
            root.left = null;
        }
        this.root = node;
    }

    Node? _first() {
        final root = this.root;
        if (root == null) return null;
        this.root = this.splayMin(root);
        return this.root;
    }

    Node? _last() {
        final root = this.root;
        if (root == null) return null;
        this.root = this.splayMax(root);
        return this.root;
    }

    void clear() {
        this.root = null;
        this.size = 0;
        this.modificationCount++;
    }

    bool has(dynamic key) {
        return this.validKey(key) && this.splay(key as K) == 0;
    }

    Comparator<K> defaultCompare() {
        return (K a, K b) => a < b ? -1 : a > b ? 1 : 0;
    }

    SplayTreeWrapper<K, Node> wrap() {
        return SplayTreeWrapper<K, Node>(
        getRoot: () => root,
        setRoot: (root) => this.root = root,
        getSize: () => size,
        getModificationCount: () => modificationCount,
        getSplayCount: () => splayCount,
        setSplayCount: (count) => splayCount = count,
        splay: (key) => splay(key),
        has: (key) => has(key),
        );
    }
}

class SplayTreeMap<K, V> extends SplayTree<K, SplayTreeMapNode<K, V>> implements Iterable<MapEntry<K, V>>, Map<K, V> {
    SplayTreeMapNode<K, V>? root = null;
    final Comparator<T> compare;

    final bool Function(dynamic) validKey;

    SplayTreeMap(this.compare, this.validKey);

    SplayTreeMap([Comparator<K>? compare, bool Function(dynamic)? isValidKKey]) : super() {
        this.compare = compare >> defaultCompare();
        this.validKey = isValidKKey ?? ((dynamic a) => a != null);
    }

    bool delete(dynamic key) {
        if (!validKey(key)) return false;
        return _delete(key as K) != null;
    }

    void forEach(void Function(V value, K key, Map<K, V>map) f) {
        final Iterable<MapEntry<K, V>> nodes = SplayTreeMapEntryIterableIterator<K, V>(wrap());
        while (nodes.moveNext()) {
            f(nodes.current.value, nodes.current.key, this);
        }
    }

    V? get(dynamic key) {
        if (!validKey(key)) return null;
        if (root != null) {
            final comp = splay(key as K);
            if (comp == 0) {
            return root!.value;
            }
        }
        return null;
    }

    bool hasValue(dynamic value) {
    final initialSplayCount = splayCount;
  
    bool visit(SplayTreeMapNode<K, V>? node) {
        while (node != null) {
            if (node.value == value) return true;
            if (initialSplayCount != splayCount) {
                throw "Concurrent modification during iteration.";
            }
            if (node.right != null && visit(node.right)) {
                return true;
            }
            node = node.left;
            }
            return false;
        }

        return visit(root);
    }

    SplayTreeMap<K, V> set(K key, V value) {
        final comp = this.splay(key);
        if (comp == 0) {
            this.root = this.root!.replaceValue(value);
            this.splayCount += 1;
            return this;
        }
        this.addNewRoot(SplayTreeMapNode(key, value), comp);
        return this;
    }

    void setAll(Map<K, V> other) {
        other.forEach((key, value) {
            this.set(key, value);
        });
    }

    V setIfAbsent(K key, V Function() IfAbsent) {
        var comp = this.splay(key);
        if (comp = 0) {
            return this.root!.value;
        }
        final modificationCount = this.modificationCount;
        final splayCount = this.splayCount;
        final value = IfAbsent();
        if (modificationCount != this.modificationCount) {
            throw "Concurrent modification during iteration.";
        }
        if (splayCount != this.splayCount) {
            comp = this.splay(key);
        }
        this.addNewRoot(SplayTreeMapNode(key, value), comp);
        return value;
    }

    bool isEmpty() {
        return this.root == null;
    }

    bool isNotEmpty() {
        return !this.isEmpty();
    }

    bool firstKey() {
        if (this.root == null) return null;
        return this._first()!.key;
    }

    bool lastKey() {
        if (this.root == null) return null;
        return this._last()!.key;
    }

    bool lastKey() {
        if (this.root == null) return null;
        return this._last()!.key;
    }

    K? lastKeyBefore(K key) {
        if (key == null) throw "Invalid argument(s)";
        if (this.root == null) return null;
        final comp = this.splay(key);
        if (comp < 0) return this.root!.key;
        
        SplayTreeMapNode<K, V>? node = this.root!.left;
        if (node == null) return null;
        
        SplayTreeMapNode<K, V>? nodeRight = node.right;
        while (nodeRight != null) {
            node = nodeRight;
            nodeRight = node.right;
        }
        return node!.key;
    }

    K? firstKeyAfter(K key) {
        if (key == null) throw "Invalid argument";
        if (this.root == null) return null;
        final comp = this.splay(key);
        if (comp > 0) return this.root!.key;
        SplayTreeMapNode<K, V>? node = this.root!.right;
        if (node == null) return null;
        nodeLeft = node.left;
        while (nodeLeft != null) {
            node = nodeLeft;
            nodeLeft = node.left;
        }
        return node!.key;
    }

    V update(K key, V Function(V value) update, [V Function()? ifAbsent]) {
        var comp = this.splay(key);
        if (comp == 0) {
            final modificationCount = this.modificationCount;
            final splayCount = this.splayCount;
            final newValue = update(this.root!.value);
            if (modificationCount != this.modificationCount) {
                throw "Concurrent modification during iteration.";
            }
            if (splayCount != this.splayCount) {
                this.splay(key);
            }
            this.root = this.root!.replaceValue(newValue);
            this.splayCount += 1;
            return newValue;
        }
        if (ifAbsent != null) {
            final modificationCount = this.modificationCount;
            final splayCount = this.splayCount;
            final newValue = ifAbsent();
            if (modificationCount != this.modificationCount) {
                throw "Concurrent modification during iteration.";
            }
            if (splayCount != this.splayCount) {
                comp = this.splay(key);
            }
            this.addNewRoot(SplayTreeMapNode(key, newValue), comp);
            return newValue;
        }
        throw "Invalid argument (key): Key not in map.";
    }

    void updateAll(V Function(K key, V value) update) {
        final root = this.root;
        if (root == null) return;
        final iterator = SplayTreeMapEntryIterableIterator(this.wrap());
        while (iterator.moveNext()) {
            final entry = iterator.current;
            final newValue = update(entry.key, entry.value);
            iterator.replaceValue(newValue);
        }
    }

    Iterable<K> keys() {
        return SplayTreeKeyIterableIterator<K, SplayTreeMapNode<K, V>>(this.wrap());
        }

        Iterable<V> values() {
        return SplayTreeValueIterableIterator<K, V>(this.wrap());
        }

        Iterable<MapEntry<K, V>> entries() {
        return this.iterator();
        }

        Iterator<MapEntry<K, V>> iterator() {
        return SplayTreeMapEntryIterableIterator<K, V>(this.wrap());
        }

        @override
        String toString() {
        return '[object Map]';
        }
}

class SplayTreeSet<E> extends SplayTree<E, SplayTreeSetNode<E>> implements Iterable<E>, Set<E> {
    SplayTreeSetNode<E>? root = null;
    final Comparator<E> _compare;

    final Predicate<dynamic> _validKey;

    SplayTreeSet([Comparator<E>? compare, Predicate<dynamic>? isValidKey]) : super() {
        _compare = compare ?? defaultCompare();
        _validKey = isValidKey ?? ((dynamic v) => v != null);
    }

    bool delete(dynamic element) {
        if (!_validKey(element)) return false;
        return _delete(element as E) != null;
    }

    bool deleteAll(Iterable<dynamic> elements) {
        for (final element in elements) {
            delete(element);
        }
    }

    void forEach(void Function(E element, E element2, Set<E> set) f) {
        final iterator = this. iterator;
        while (iterator.moveNext()) {
            final value = iterator.current;
            f(value, value, this);
        }
    }

    SplayTreeSet<E> add(E element) {
        final compare = splay(element);
        if (compare != 0) addNewRoot(SplayTreeSetNode<E>(element), compare);
        return this;
    }

    SplayTreeSet<E> addAndReturn(E element) {
        final compare = this.splay(element);
        if (compare != 0) this.addNewRoot(SplayTreeSetNode<E>(element), compare);
        return this.root!.key;
    }

    void addAll(Iterable<E> elements) {
        for (final element in elements) {
            this.add(element);
        }
    }

    bool isEmpty() {
        return this._root = null;
    }

    bool isNotEmpty() {
        return this._root != null;
    }

    E single() {
        if (this.size == 0) throw 'Bad state: No element';
        if (this.size > 1) throw 'Bad state: Too many element';
        return this._root!.key;
    }

    E first() {
        if (this.size == 0) throw 'Bad state: No element';
        return this._first()!.key;
    }

    E last() {
        if (this.size == 0) throw "Bad state: No element";
        return this._last()!.key;
    }

    E? lastBefore(E element) {
        if (element == null) throw 'Invalid argument(s)';
        if (this._root == null) return null;
        final comp = this.splay(element);
        if (comp < 0) return this._root!.key;
        SplayTreeSetNode<E>? node = this._root!.left;
        if (node == null) return null;
        var nodeRight = node.right;
        while (nodeRight != null) {
            node = nodeRight;
            nodeRight = node.right;
        }
        return node!.key;
    }

    E? firstAfter(E element) {
        if (element == null) throw "Invalid argument(s)";
        if (this._root == null) return null;
        final comp = this.splay(element);
        if (comp > 0) return this._root!.key;
        SplayTreeSetNode<E>? node = this._root!.right;
        if (node == null) return null;
        var nodeRight = node.right;
        while (nodeRight != null) {
            node = nodeRight;
            nodeRight = node.right;
        }
        return node!.key;
    }

    void retainAll(Iterable<dynamic> elements) {
        final retainSet = SplayTreeSet<E>(this._compare, this._validKey);
        final modificationCount = this.modificationCount;
        for (final object in elements) {
            if (modificationCount != this.modificationCount) {
            throw 'Concurrent modification during iteration.';
            }
            if (this._validKey(object) && this.splay(object as E) == 0) {
            retainSet.add(this._root!.key);
            }
        }
        if (retainSet.size != this.size) {
            this._root = retainSet._root;
            this.size = retainSet.size;
            this.modificationCount++;
        }
    }

    E? lookup(dynamic object) {
        if (!this._validKey(object)) return null;
        final comp = this.splay(object as E);
        if (comp != 0) return null;
        return this._root!.key;
    }

    Set<E> intersection(Set<dynamic> other) {
        final result = SplayTreeSet<E>(this._compare, this._validKey);
        for (final element in this) {
            if (other.contains(element)) result.add(element);
        }
        return result;
    }

    Set<E> difference(Set<dynamic> other) {
        final result = SplayTreeSet<E>(this._compare, this._validKey);
        for (final element in this) {
            if (!other.contains(element)) result.add(element);
        }
        return result;
    }

    Set<E> union(Set<E> other) {
        final u = this.clone();
        u.addAll(other);
        return u;
    }

    SplayTreeSet<E> clone() {
        final set = SplayTreeSet<E>(this._compare, this._validKey);
        set.size = this.size;
        set._root = this.copyNode<SplayTreeSetNode<E>>(this._root);
        return set;
    }

    Node? copyNode<Node extends SplayTreeNode<E, Node>>(Node? node) {
        if (node == null) return null;
        
        SplayTreeSetNode<E>? copyChildren(Node node, SplayTreeSetNode<E> dest) {
            Node? left;
            Node? right;
            do {
            left = node.left;
            right = node.right;
            if (left != null) {
                final newLeft = SplayTreeSetNode<E>(left.key);
                dest.left = newLeft;
                copyChildren(left, newLeft);
            }
            if (right != null) {
                final newRight = SplayTreeSetNode<E>(right.key);
                dest.right = newRight;
                node = right;
                dest = newRight;
            }
            } while (right != null);
            return dest;
        }
        
        final result = SplayTreeSetNode<E>(node.key);
        copyChildren(node, result);
        return result as Node;
    }

    Set<E> toSet() {
        return clone();
    }

    Iterable<MapEntry<E, E>> entries() {
        return _SplayTreeSetEntryIterable<E, SplayTreeSetNode<E>>(this.wrap());
    }

    Iterable<E> keys() {
        return this;
    }

    Iterable<E> values() {
        return this;
    }

    @override
    Iterator<E> get iterator {
        return _SplayTreeKeyIterator<E, SplayTreeSetNode<E>>(this.wrap());
    }

    @override
    String toString() {
        return 'SplayTreeSet';
    }
}

abstract class SplayTreeWrapper<K, Node extends SplayTreeNode<K, Node>> {
    Node? getRoot();
    void setRoot(Node? root);
    int getSize();
    int getModificationCount();
    int getSplayCount();
    void setSplayCount(int count);
    int splay(K key);
    bool has(dynamic key);
}

abstract class SplayTreeIterableIterator<K, Node extends SplayTreeNode<K, Node>, T> implements Iterator<T> {
    final SplayTreeWrapper<K, Node> tree;
    final List<Node> path = <Node>[];
    int? modificationCount = null;
    int splayCount;

    SplayTreeIterableIterator(SplayTreeWrapper<K, Node> tree) {
        this.tree = tree;
        this.splayCount = tree.getSplayCount();
    }

    T? current() {
        if (path.isEmpty) return null;
        final node = path[path.length - 1];
        return getValue(node);
    }

    void rebuildPath(K key) {
            path.clear();
            tree.splay(key);
            path.add(tree.getRoot()!);
            splayCount = tree.getSplayCount();
        }

    void findLeftMostDescendent(Node? node) {
            while (node != null) {
            path.add(node);
            node = node.left;
            }
        }

      bool moveNext() {
            if (modificationCount != tree.getModificationCount()) {
            if (modificationCount == null) {
                modificationCount = tree.getModificationCount();
                Node? node = tree.getRoot();
                while (node != null) {
                path.add(node);
                node = node.left;
                }
                return path.isNotEmpty;
            }
            throw "Concurrent modification during iteration.";
            }
            if (path.isEmpty) return false;
            if (splayCount != tree.getSplayCount()) {
            rebuildPath(path[path.length - 1].key);
            }
            Node node = path[path.length - 1];
            Node? next = node.right;
            if (next != null) {
            while (next != null) {
                path.add(next);
                next = next.left;
            }
            return true;
            }
            path.removeLast();
            while (path.isNotEmpty && path[path.length - 1].right == node) {
            node = path.removeLast()!;
            }
            return path.isNotEmpty;
        }

        T getValue(Node node);
}

class SplayTreeKeyIterator<K, Node extends SplayTreeNode<K, Node>> extends SplayTreeIterableIterator<K, Node, K> {
    SplayTreeKeyIterator(SplayTreeWrapper<K, Node> tree) : super(tree);

    @override
    K getValue(Node node) {
        return node.key;
    }
}

class SplayTreeSetEntryIterator<K, Node extends SplayTreeNode<K, Node>> extends SplayTreeIterableIterator<K, Node, MapEntry<K, K>> {
    SplayTreeSetEntryIterator(SplayTreeWrapper<K, Node> tree) : super(tree);

    @override
    MapEntry<K, K> getValue(Node node) {
        return MapEntry(node.key, node.key);
    }
}

class SplayTreeValueIterator<K, V> extends SplayTreeIterableIterator<K, SplayTreeMapNode<K, V>, V> {
    SplayTreeValueIterator(SplayTreeMapWrapper<K, V> map) : super(map);

    @override
    V getValue(SplayTreeMapNode<K, V> node) {
        return node.value;
    }
}

class SplayTreeMapEntryIterator<K, V> extends SplayTreeIterableIterator<K, SplayTreeMapNode<K, V>, MapEntry<K, V>> {
    SplayTreeMapEntryIterator(SplayTreeMapWrapper<K, V> map) : super(map);

    @override
    MapEntry<K, V> getValue(SplayTreeMapNode<K, V> node) {
        return MapEntry(node.key, node.value);
    }

    void replaceValue(V value) {
        if (modificationCount != tree.getModificationCount()) {
        throw "Concurrent modification during iteration.";
        }
        if (splayCount != tree.getSplayCount()) {
        rebuildPath(path[path.length - 1].key);
        }
        final last = path.removeLast()!;
        final newLast = last.replaceValue(value);
        if (path.isEmpty) {
        tree.setRoot(newLast);
        } else {
        final parent = path[path.length - 1];
        if (last == parent.left) {
            parent.left = newLast;
        } else {
            parent.right = newLast;
        }
        }
        path.add(newLast);
        final count = tree.getSplayCount() + 1;
        tree.setSplayCount(count);
        splayCount = count;
    }
}