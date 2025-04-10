typedef Comparator<T> = int Function(T a, T b);
typedef Predicate<T> = bool Function(T value);

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

    Node addNewRoot(Node node, )
}