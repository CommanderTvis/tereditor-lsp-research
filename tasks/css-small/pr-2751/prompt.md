Caret size in docs nav links rather small after recent commits

I only just noticed it now, but it looks like changes made in https://github.com/tabler/tabler/pull/2536 included shrinking the size of the caret used in the documentation's nav links.
The change is presumably coming from this line:
https://github.com/tabler/tabler/blob/83ec6f8bcc6cca16945751e573f8401aa4737c3d/core/scss/_variables.scss#L903

I'm not sure if I'm going to be the only one that thinks this, but I think that the carets are now too small.
@codecalm - was there any particularly useful reason to make them smaller? the original width and height of 0.36em seemed fine to me.

@kevinpapst - you've been fairly vocal in the past about usability/accessibility etc - what do you think?

Original caret size:
<img width="232" height="79" alt="Image" src="https://github.com/user-attachments/assets/d03849c5-d333-4fc4-a060-5edc09dd064c" />

New caret size:
<img width="234" height="102" alt="Image" src="https://github.com/user-attachments/assets/b87b7093-1597-430d-9f8d-6598f9d2fedb" />

(Incidentally, when looking at the live preview where I noticed this, (https://tabler-docs-git-dev-docs-improvements-2-tabler-io.vercel.app/ui) I can see that the navigation menu is not set up to collapse at the right points. This may be due to WIP not yet completed though, not sure, as I haven't fully investigated that).
