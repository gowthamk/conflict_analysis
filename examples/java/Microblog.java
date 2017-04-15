
import java.util.ArrayList;
import java.util.Collections;
import java.util.Iterator;
import java.util.NoSuchElementException;
import java.util.Random;
import java.util.Set;
import java.util.concurrent.ConcurrentSkipListSet;

class Assert {
  public static void doIt(Boolean b) { /* ... */}
  
  public static void userUniqueness(Set<User> us) {
    for(User u1: us) {
      for(User u2: us) {
        Assert.doIt((u1 == u2) || (u1.id != u2.id && 
                       u1.email != u2.email));
      }
    }
  }
  
  public static void userPostFkey(Set<User> us, Set<Micropost> ms) {
    for(Micropost m: ms) {
      User author = null;
      for(User u:us) {
        if(m.authorId == u.id) {
          author = u;
          break;
        }
      }
      Assert.doIt(author!=null);
    }
  }
}

class User implements java.lang.Comparable<User>{
  int id;
  String name;
  String email;
  public User(int id, String name, String email) {
    this.id=id; this.name=name; this.email=email;
  }
  
  public int compareTo(User u) {
    return (Integer.compare(this.hashCode(), u.hashCode()));
  }
  
  
  /* save transaction; saves user into a collection */
  public void save(Set<User> s) {
    User u = null;
    
    /* check whether the user with id and email is present; see u2 */
    for(User u2: s) {
      if(u2.id == this.id || u2.email == this.email) {
        u=u2;
        break;
      }
    }
    /* if user is not present already, add */
    if(u == null) {
      s.add(this);
    }
    // assert s does not contain two users with same ids or same emails.
    Assert.userUniqueness(s); 
  }
  /*
   * delete transaction: delete user us from the set of users; dependent destroy
   */
  public void delete(Set<User> us, Set<Micropost> ms) {
    /* remove the microposts first corresponding to the user */
    for(Micropost m: ms) {
      if(m.authorId == this.id)
        ms.remove(m);
    }
    
    /* remove the user from the table */
    us.remove(this);
    // assert that no entry in ms exists where the author id is this.id
    Assert.userPostFkey(us, ms);
  }
}

class Micropost implements java.lang.Comparable<Micropost> {
  int id;
  String content;
  int authorId;
  public Micropost(int id, String content, int authorId) {
    this.id=id; this.content=content; this.authorId=authorId;
  }
  public int compareTo(Micropost m) {
    return (Integer.compare(this.hashCode(), m.hashCode()));
  }
  
  public void save(Set<User> us, Set<Micropost> ms) {
    for(User u: us){
      if(u.id == this.authorId) {
        ms.add(this);
      }
    }
    // assert that no entry in ms exists where the author id is this.id
    Assert.userPostFkey(us, ms);
  }
}

public class Microblog {
  public static int NUM_ROUNDS = 1000;
  public static int NUM_USERS = 100;
  public static int NUM_POSTS_PER_USER = 50;
  
  /*
   * A sample test to demonstrate uniqueness violation.
   * Note: this code need not be analyzed. 
   */
  public static void testUserUniqueness() {
    Set<User> s = new ConcurrentSkipListSet<User>();
    Random rand = new Random();
    for(int i=0; i<NUM_ROUNDS; i++){
      String name = "name"+(Integer.toString(i));
      String email = name+"@purdue.edu";
      Thread t1 = new Thread(new Runnable() {
        public void run() {
          (new User(rand.nextInt(),name,email)).save(s);
        }
      });
      Thread t2 = new Thread(new Runnable() {
        public void run() {
          (new User(rand.nextInt(),name,email)).save(s);
        }
      });
      t1.start();
      t2.start();
      try{
        t1.join();
        t2.join();  
      } catch(InterruptedException e) {
        //do nothing
      }
    }
    Iterator<User> iter = s.iterator();
    while(iter.hasNext()) {
      User u = iter.next();
      iter.remove();
      if(s.stream().anyMatch(uu -> uu.id == u.id || 
                     uu.email == u.email)) {
        System.out.println("Duplicates detected!");
      }
    }
  }
  /*
   * A sample test to demonstrate referential integrity violation.
   * Note: this code need not be analyzed.
   */
  public static void testMicropostFkey() {
    Set<User> us = new ConcurrentSkipListSet<User>();
    Set<Micropost> ms = new ConcurrentSkipListSet<Micropost>();
    Random rand = new Random();
    /*
     * Populate DB
     */
    for(int i=0; i<NUM_USERS; i++){
      String name = "name"+(Integer.toString(i));
      String email = name+"@purdue.edu";
      (new User(i,name,email)).save(us);
    }
    for(int i=0; i<NUM_USERS; i++){
      ArrayList<Thread> threads = new ArrayList<Thread>();
      threads.add(new Thread(new Runnable() {
        public void run() {
          try {
            User usr = us.stream().findAny().get();
            usr.delete(us,ms);
          } catch(NoSuchElementException e) {}
        }
      }));
      for(int j=0; j<NUM_POSTS_PER_USER; j++) {
        threads.add(new Thread(new Runnable() {
          public void run() {
            try {
              int authorId = us.stream().findAny().get().id;
              Micropost m = new Micropost(rand.nextInt(), 
                  "content", authorId);
              m.save(us, ms);
            } catch(NoSuchElementException e) {}
          }
        }));
      }
      Collections.shuffle(threads);
      threads.stream().forEachOrdered(t -> t.start());
      threads.stream().forEachOrdered(t -> {try { t.join(); } 
                         catch (InterruptedException e) {
                           //do nothing
                         }});
      
    }
     
    if (us.size() != 0) {
      System.out.println("Er.. wat?");
    }
    if (ms.size() != 0) {
      System.out.println("Referential integrity violated!");
    }
  }
    
  
  public static void main(String[] args) {
    System.out.println("Hello World");
    testUserUniqueness();
    testMicropostFkey();
  }
}
