package nl.hro.cmibod12p.common;

import java.util.List;
import java.util.Map;

public interface ListMap<K, V> extends Map<K, List<V>> {
	V getFirst(K key);

	boolean add(K key, V value);
}
