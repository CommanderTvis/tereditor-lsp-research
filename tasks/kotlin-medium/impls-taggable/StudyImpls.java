import java.io.File;
import java.net.URL;
import java.net.URLClassLoader;
import java.nio.file.*;
import java.util.*;

/**
 * java StudyImpls.java <type> <classpath> <class-dir>...: every named class in the class directories that is a subtype
 * of the type (by the JVM's own isAssignableFrom), as a source-level fully qualified name (nested classes with '.').
 * Anonymous, local and synthetic classes are skipped. Classes are loaded without initialisation.
 */
public class StudyImpls {
  public static void main(String[] a) throws Exception {
    List<URL> urls = new ArrayList<>();
    for (String p : a[1].split(File.pathSeparator)) if (!p.isEmpty()) urls.add(new File(p).toURI().toURL());
    for (int i = 2; i < a.length; i++) urls.add(new File(a[i]).toURI().toURL());
    URLClassLoader cl = new URLClassLoader(urls.toArray(new URL[0]), StudyImpls.class.getClassLoader());
    Class<?> base = Class.forName(a[0], false, cl);
    TreeSet<String> out = new TreeSet<>();
    for (int i = 2; i < a.length; i++) {
      Path root = Paths.get(a[i]);
      if (!Files.isDirectory(root)) continue;
      try (var s = Files.walk(root)) {
        for (Path p : (Iterable<Path>) s::iterator) {
          String f = root.relativize(p).toString();
          if (!f.endsWith(".class") || f.endsWith("module-info.class")) continue;
          String name = f.substring(0, f.length() - 6).replace('/', '.');
          Class<?> c;
          try { c = Class.forName(name, false, cl); } catch (Throwable t) { System.err.println("skip " + name + ": " + t); continue; }
          if (c == base || !base.isAssignableFrom(c) || c.isAnonymousClass() || c.isLocalClass() || c.isSynthetic()) continue;
          out.add(c.getCanonicalName() != null ? c.getCanonicalName() : name);
        }
      }
    }
    out.forEach(System.out::println);
  }
}
