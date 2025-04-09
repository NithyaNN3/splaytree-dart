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